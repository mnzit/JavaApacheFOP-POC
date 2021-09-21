package finwell.repository.base.assessment;


import static com.bofa.ecom.finwell.assessment.constants.AssessmentConstants.*

import javax.xml.transform.Result
import javax.xml.transform.Source
import javax.xml.transform.Transformer
import javax.xml.transform.sax.SAXResult
import javax.xml.transform.sax.SAXSource

import org.apache.commons.io.IOUtils
import org.apache.commons.text.StringEscapeUtils
import org.apache.commons.text.WordUtils
import org.apache.fop.apps.Fop
import org.apache.fop.apps.FopFactory
import org.apache.fop.apps.MimeConstants
import org.xml.sax.InputSource

import com.bac.omni.finwell.assessment.v1.question.QuestionResponse
import com.bofa.ecom.common.appcontext.AppContext
import com.bofa.ecom.common.appcontext.AppContextProvider
import com.bofa.ecom.common.core.logging.Log
import com.bofa.ecom.common.core.logging.LogFactory
import com.bofa.ecom.finwell.assessment.constants.AssessmentConstants
import com.bofa.ecom.finwell.assessment.model.AssessmentRequestContainer
import com.bofa.ecom.finwell.assessment.model.AssessmentResponseContainer
import com.bofa.ecom.finwell.assessment.model.AssessmentWrapper
import com.bofa.finwell.assessment.v1.action.ActionGroup
import com.bofa.finwell.assessment.v1.action.FootNote
import com.bofa.finwell.assessment.v1.download.DownloadRequest
import com.bofa.finwell.assessment.v1.download.FooterContentTable
import com.bofa.omni.greco.framework.GrecoEngine
import com.bofa.omni.greco.model.RulesData;

import groovy.text.Template
import groovy.transform.CompileStatic

@CompileStatic
public class AssessmentPDFRepository{
    private static final Log LOGGER = LogFactory.getLog(AssessmentPDFRepository.class);

    private static final String ERROR_CODE = "DOWNLOAD"
    private static final String FOOTNOTE_REG_TOKEN="\\{FN_(\\d+)\\}"

    def validateRequest(RulesData data) {
        LOGGER.info("Validate Download PDF Request")

        //Validate Party Id and UFID
        getGrecoEngine().executeRule("base.assessment.datasource.common.repository", "validateCustomerIdentifier", data, ERROR_CODE);

        return Boolean.TRUE
    }

    def prepareRequestContainer(RulesData data) {
        LOGGER.info "Prepare Request Container"

        AssessmentRequestContainer container= new AssessmentRequestContainer()
        //TODO: Is this required?
        DownloadRequest request = (DownloadRequest)data[AssessmentConstants.REQUEST]
        container.downloadRequest=request
        container.locale=(String)data[Common.LOCALE]

        data[REQUEST_CONTAINER]=container
        return Boolean.TRUE
    }

    def getAllAnswerdQuestions(RulesData data) {
        LOGGER.info "Get All Questions answered for current Assessment"
        AssessmentWrapper cacheWrapper=(AssessmentWrapper)grecoEngine.executeRule("base.assessment.common.repository","fetchLocalCache")
        getGrecoEngine().executeRule("base.assessment.datasource.afdw.questions.repository", "getQuestions", data,null,cacheWrapper.frameworkId,"ALL")
        return Boolean.TRUE
    }


    def prepareResponse(RulesData data) {
        LOGGER.info "Prepare Downalod PDF Response"

        DownloadRequest request = (DownloadRequest)data[AssessmentConstants.REQUEST]
        AssessmentWrapper cacheWrapper=(AssessmentWrapper)grecoEngine.executeRule("base.assessment.common.repository","fetchLocalCache")
        List<ActionGroup> actionGroups = (List<ActionGroup>)grecoEngine.executeRule("base.assessment.actions.retrieve.repository","prepareActionGroups",cacheWrapper,true)
        List<FootNote> footNotes=(List<FootNote>)grecoEngine.executeRule("base.assessment.actions.retrieve.repository","prepareFootNotes",actionGroups)
        def binding=[:]
        binding.name=WordUtils.capitalizeFully("${cacheWrapper.profile.firstName} ${cacheWrapper.profile.lastName}")
        binding.score=cacheWrapper.score
        binding.lastAssessmentDateLabel=escapeXml10(request.payload.labelContent.lastAssessmentDateLabel)
        binding.preparedForLabel=escapeXml10(request.payload.labelContent.preparedForLabel)
        binding.finwellDescription=escapeXml10(request.payload.labelContent.finwellDescription)
        binding.qAndALabel=escapeXml10(request.payload.labelContent.questionsAndAnswersTitle)
        binding.title=escapeXml10(request.payload.labelContent.title)
        binding.outOfScoreLabel=escapeXml10(request.payload.labelContent.outOfScoreLabel)
        binding.logoAltText=escapeXml10(request.payload.alternateContent.logoAltText)
        binding.scoreAltText=escapeXml10(request.payload.alternateContent.scoreAltText)
        binding.metadataTitle=escapeXml10(request.payload.alternateContent.title)
        binding.metadataDescription=escapeXml10(request.payload.alternateContent.description)



        binding.footerContentAllPageExceptLast=escapeXml10(request.payload.footerContent.allPageExceptLast)
        binding.footerContentTableString=getTableString(request.payload.footerContent.table)
        binding.footerContentTableTitle=escapeXml10(request.payload.footerContent.table.title)
        binding.disclosuresBeforeTable=request.payload.footerContent.disclosuresBeforeTable
        binding.disclosuresAfterTable=request.payload.footerContent.disclosuresAfterTable
        binding.disclaimers=request.payload.footerContent.disclaimers
        binding.footNoteRegToken=FOOTNOTE_REG_TOKEN
        AssessmentResponseContainer responseContainer = (AssessmentResponseContainer)data[AssessmentConstants.RESPONSE_CONTAINER]
        QuestionResponse questionResponse = responseContainer.questionResponse
        def questions = questionResponse?.payload?.questions.sort{
            it.order
        }

        if(questions) {
            LOGGER.info "Questions To Be added into PDF is ${questions.collect{it.id}}"
            binding.questions=questions
        }
        binding.actionGroups=actionGroups
        if(cacheWrapper.lastAssessmentDate) {
            binding.lastAssessmentDate=new java.text.SimpleDateFormat("MMM dd, YYYY").format(cacheWrapper.lastAssessmentDate)
        }

        binding.sponsorContents=request.payload.sponsorContents
        def footnotes=[:]
        if(footNotes) {
            footnotes=footNotes.collectEntries { [it.id,it.descriptions] }
        }
        binding.footnotes=footnotes
        ByteArrayOutputStream out = new ByteArrayOutputStream()
        preparePdf(prepareFOString(binding), createFop(out), getTransformer())

        byte[] content =out.toByteArray()
        IOUtils.closeQuietly(out)

        data[RESPONSE]=content
        return Boolean.TRUE
    }

    private String escapeXml10(String text) {
        return StringEscapeUtils.escapeXml10(text)
    }

    def String getTableString(FooterContentTable table) {
        StringBuilder sb = new StringBuilder()
        table.entries.eachWithIndex { entry,index->
            sb.append(entry)
            if((index+1)%3==0) {
                sb.append(":")
            }else {
                sb.append(",")
            }
        }
        sb.deleteCharAt(sb.size()-1)

        return sb.toString()
    }

    private void preparePdf(String foString, Fop fop, Transformer transformer) throws Exception{
        // Setup input and output for XSLT transformation
        //LOGGER.info "${foString}"
        Source src = new SAXSource(new InputSource(new StringReader(foString)))

        // Resulting SAX events (the generated FO) must be piped through to FOP
        Result res = new SAXResult(fop.getDefaultHandler())

        // Start XSLT transformation and FOP processing
        LOGGER.info "Generating PDF"
        transformer.transform(src, res)
    }

    // removed as footnote space issue been resolved
    // private String minifyXML(String source) {
    // 	BufferedReader reader = new BufferedReader(new StringReader(source))
    // 	StringBuilder buffer = new StringBuilder(source.size())
    // 	reader.eachLine {
    // 		buffer.append(it.trim())
    // 	}
    // 	IOUtils.closeQuietly(reader)
    // 	return buffer.toString()
    // }

    private String prepareFOString(Object binding) {

        Template template = (Template)getContext().getObject("assessment.download.pdf.fo.template")
        Writable wrt =template.make((Map)binding)

        //ByteArrayOutputStream os = new ByteArrayOutputStream()
        //wrt.writeTo(new BufferedWriter(new OutputStreamWriter(os)))
        return wrt.toString()
    }

    private Fop createFop( OutputStream out) {
        LOGGER.info "Creating FOP instance with PDF mime type"
        FopFactory fopFactory =  (FopFactory)getContext().getObject("assessment.download.pdf.fop.factory")
        return fopFactory.newFop(MimeConstants.MIME_PDF, out)
    }

    private Transformer getTransformer() {
        return (Transformer)getContext().getObject("xml.transformer")
    }

    private AppContext getContext() {
        return AppContextProvider.getContext();
    }

    private  GrecoEngine getGrecoEngine() {
        return (GrecoEngine) getContext().getObject("grecoEngine");
    }
}
