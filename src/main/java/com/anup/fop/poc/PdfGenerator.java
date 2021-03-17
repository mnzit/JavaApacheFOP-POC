package com.anup.fop.poc;

import org.apache.avalon.framework.configuration.Configuration;
import org.apache.avalon.framework.configuration.DefaultConfigurationBuilder;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang3.StringEscapeUtils;
import org.apache.fop.apps.*;
import org.apache.xalan.xsltc.compiler.Template;
import org.xml.sax.SAXException;

import javax.xml.transform.*;
import javax.xml.transform.sax.SAXResult;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.util.Map;

/**
 * Generate a PDF file using XML data and XSLT stylesheets
 */
public class PdfGenerator {

    public void createPdfFile(String configFile, String xmlDataFile, String templateFile, OutputStream pdfOutputStream) throws IOException, SAXException, TransformerException {
        System.out.println("Create pdf file ...");
        File tempFile = File.createTempFile("fop-" + System.currentTimeMillis(), ".pdf");

        //  holds references to configuration information and cached data
        //  reuse this instance if you plan to render multiple documents
        //  holds references to configuration information and cached data
        //  reuse this instance if you plan to render multiple documents
//
        try {
        DefaultConfigurationBuilder cfgBuilder = new DefaultConfigurationBuilder();
        Configuration cfg = cfgBuilder.buildFromFile(new File(configFile));
        FopFactoryBuilder fopFactoryBuilder = new FopFactoryBuilder(new File(".").toURI()).setConfiguration(cfg);
        FopFactory fopFactory = fopFactoryBuilder.build();


//        FopFactory fopFactory = FopFactory.newInstance(new File(".").toURI());
        FOUserAgent userAgent = fopFactory.newFOUserAgent();


            // set output format
            Fop fop = fopFactory.newFop(MimeConstants.MIME_PDF, userAgent, pdfOutputStream);

            // Load template
            TransformerFactory transformerFactory = TransformerFactory.newInstance();
            Transformer transformer = transformerFactory.newTransformer(new StreamSource(new File(templateFile)));

            // Set value of parameters in stylesheet
            transformer.setParameter("version", "1.0");

            FileInputStream fin=new FileInputStream(xmlDataFile);

            String body = IOUtils.toString(fin, StandardCharsets.UTF_8.name());

            body =  StringEscapeUtils.unescapeJava(body);

            // Input for XSLT transformations
            Source xmlSource = new StreamSource(IOUtils.toInputStream(body));


            Result result = new SAXResult(fop.getDefaultHandler());


            transformer.transform(xmlSource, result);
        } catch(Exception ex){
            System.out.println(ex.getMessage());
        }finally {
            tempFile.delete();
        }
    }

}
