<?xml version="1.0" encoding="utf-8" ?>
<fo:root
        xml:lang="en-US"
        xmlns:fo="http://www.w3.org/1999/XSL/Format"
        xmlns:fox="http://xmlgraphics.apache.org/fop/extensions"
        xmlns:gsp='http://groovy.codehaus.org/2005/gsp'
        xmlns:svg='http://www.w3.org/2000/svg'
        font-family="any" font-style="normal" font-weight="normal">
    <fo:layout-master-set>
        <fo:simple-page-master page-width="1024px" page-height="1326px" margin="50px 0px 0px 0px" master-name="all-except-last-page">
            <fo:region-body margin="0px 0px 80px 0px" />
            <fo:region-after region-name="all-except-last-page-footer" extent="80px"/>
        </fo:simple-page-master>
        <fo:simple-page-master page-width="1024px" page-height="1326px" margin="50px 0px 0px 0px" master-name="last-page">
            <fo:region-body margin="0px 0px 0px 0px" />
            <fo:region-after region-name="last-page-footer" extent="0px"/>
        </fo:simple-page-master>
        <fo:page-sequence-master master-name="all-pages">
            <fo:repeatable-page-master-alternatives>
                <fo:conditional-page-master-reference page-position="last" master-reference="last-page"/>
                <fo:conditional-page-master-reference page-position="any" master-reference="all-except-last-page"/>
            </fo:repeatable-page-master-alternatives>
        </fo:page-sequence-master>
    </fo:layout-master-set>
    <fo:declarations>
        <x:xmpmeta xmlns:x="adobe:ns:meta/">
            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
                <rdf:Description rdf:about="" xmlns:dc="http://purl.org/dc/elements/1.1/">
                    <dc:title>$metadataTitle</dc:title>
                    <dc:creator>$logoAltText</dc:creator>
                    <dc:description>$metadataDescription</dc:description>
                </rdf:Description>
            </rdf:RDF>
        </x:xmpmeta>
    </fo:declarations>
    <fo:page-sequence master-reference="all-pages">
        <fo:static-content flow-name="all-except-last-page-footer">
            <fo:block margin="18px 30px 40px 30px"  line-height="120%" font-family="regular" font-style="normal" font-weight="normal">
                <fo:table >
                    <fo:table-column column-width="550px"/>
                    <fo:table-column />
                    <fo:table-body>
                        <fo:table-row>
                            <fo:table-cell display-align="center">
                                <fo:block text-align="left" font-size="13px">$footerContentAllPageExceptLast</fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
                                <fo:block text-align="right" font-size="28px">$title | <fo:page-number/></fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:block>
        </fo:static-content>

        <fo:flow flow-name="xsl-region-body">
            <gsp:scriptlet>def logoPath = Thread.currentThread().getContextClassLoader().getResource("com/bofa/ecom/finwell/assessment/pdf/Logo-Merrill.png").toURI()</gsp:scriptlet>
            <fo:block font-family="regular" font-style="normal" font-weight="normal"> <!-- FO Block For Body -->
                <fo:block margin="0px 0px 0px 60px" space-after="40px">
                    <fo:external-graphic src="url(${logoPath})" fox:alt-text="${logoAltText}" content-type="content-type:image/png">
                    </fo:external-graphic>
                </fo:block>
                <fo:block role="H1" text-align="center" space-after="25px" font-size="28px"  line-height="120%">$preparedForLabel: $name</fo:block>
                <fo:block text-align="center" padding="10px 0px 10px 0px" height="45px" background-color="#EDEDED" space-after="40px">
                    <fo:inline font-size="20px" line-height="120%">$lastAssessmentDateLabel: $lastAssessmentDate </fo:inline>
                </fo:block>
                <!-- Score and related text -->
                <gsp:scriptlet>
                    def width = 219, height = 219
                    def angleDistance=18, startAngle=270
                    def points=0..19
                    def bigPointRadious=15, pointRadious=9.5
                    float scoreCircleR = (width-(bigPointRadious*2))/2
                    float centerX=width/2, centerY=height/2
                    int pointToHighlight = score/5
                    def colors=["#EFA902","#DCAB14","#DCAB14","#DCAB15","#D3AD1C","#D3AD1C","#B6B039","#B6B039","#B6B039","#A2B34C","#97B556","#91B55C","#91B55C","#88B765","#7EB86E","#61BC8A","#60BC8B","#55BD96","#4EBE9D","#44C0A7"]
                    def emptyPointColor="#D8D8D8", maxScorePointColor="#006980"
                </gsp:scriptlet>
                <fo:block space-after="40px" height="${height}px">
                    <fo:float float="start">
                        <fo:block margin="0px 150px" >
                            <fo:instream-foreign-object fox:alt-text="$score $outOfScoreLabel $scoreAltText" content-type="namespace-prefix:svg">
                                <svg:svg height="${height}px" width="${width}px" viewport="0px 0px ${width}px ${height}px">
                                    <svg:text x='50%' y='118px' font-family="regular" font-style="normal" font-weight="normal" font-size="55px" fill="#012169" text-anchor="middle">$score</svg:text>
                                    <svg:text x='50%' y='138px' font-family="regular" font-style="normal" font-weight="normal" font-size="16px" fill="#012169" text-anchor="middle">$outOfScoreLabel</svg:text>
                                    <gsp:scriptlet>
                                        points.each {
                                        def angle = (startAngle+(it*angleDistance))%360
                                        def radiant= (angle*3.14)/180
                                        def x = (scoreCircleR*Math.cos(radiant))+centerX
                                        def y = (scoreCircleR*Math.sin(radiant))+centerY
                                        def r=pointRadious
                                        if(it==pointToHighlight) {
                                        r=bigPointRadious
                                        }
                                        def color=null
                                        if(pointToHighlight==20 &amp;&amp; it==0) {
                                        color=maxScorePointColor
                                        r=bigPointRadious
                                        }
                                        else if(it>pointToHighlight){
                                        color=emptyPointColor
                                        }
                                        else {
                                        color=colors[it]
                                        }
                                    </gsp:scriptlet>
                                    <svg:circle cx="$x" cy="$y" r="$r" stroke="none" fill="$color"/>
                                    <gsp:scriptlet>}</gsp:scriptlet>
                                </svg:svg>
                            </fo:instream-foreign-object>
                        </fo:block>
                    </fo:float>
                    <fo:block-container display-align="center" height="${height}px"  >
                        <fo:block margin="0px 206px" font-family="medium" font-style="normal" font-weight="500" font-size="20px" space-after="25px" line-height="120%">
                            $finwellDescription
                        </fo:block>
                    </fo:block-container>
                </fo:block>
                <fo:block></fo:block> <!-- Clears floating -->
                <!-- Questions and Answers -->
                <fo:block space-after="60px">
                    <fo:block role="H2" space-after="40px" padding-top="10px" padding-bottom="10px" font-size="20px"  line-height="120%"  background-color="#EDEDED">
                        <fo:inline padding-left="60px" font-family="medium" font-style="normal" font-weight="500">$qAndALabel</fo:inline>
                    </fo:block>
                    <gsp:scriptlet>
                        questions.eachWithIndex{qn, index->
                        def no = index+1
                        def qnText = org.apache.commons.text.StringEscapeUtils.escapeXml10(qn.description)
                    </gsp:scriptlet>
                    <fo:block keep-together.within-page="always"  line-height="120%" font-size="18px" role="P">
                        <fo:block  margin-left="60px" margin-right="60px" padding-top="10px" padding-bottom="10px" space-after="25px" background-color="#EDEDED" >
                            <fo:block margin-left="20px" margin-right="20px">$no. $qnText</fo:block>
                        </fo:block>
                        <fo:block space-after="25px" margin-left="100px" margin-right="80px"> <!-- Answer Block -->
                            <gsp:scriptlet> <!-- Answer Loop -->
                                def qnTemplate = qn.templateId
                                def ansDesc=[]

                                def selectedAns =qn.answers.findAll{it.selection==true}.sort{it.order}
                                def childAns = []
                                selectedAns.each{
                                if(it.answers){
                                childAns.addAll(it.answers)
                                }
                                }
                                if(qnTemplate=="CHK" &amp;&amp; childAns.any{it.templateId=="ETX_DEP"}){
                                selectedAns.each{
                                if(it.answers){
                                ansDesc.add("${it.description} (${it.answers[0].value})")
                                }else{
                                ansDesc.add("${it.description}")
                                }
                                }
                                }
                                else if(qnTemplate=="TXT_GRP"){
                                selectedAns.each{
                                def dollerAmount=java.text.NumberFormat.getCurrencyInstance().format(new BigDecimal(it.value))
                                ansDesc.add("${it.description} ${dollerAmount}")
                                }
                                }
                                else if(qnTemplate=="CHK"){
                                StringBuilder sb = new StringBuilder()
                                selectedAns.each{ ans ->
                                if(ans.answers &amp;&amp; ans.answers.any{it.selection==true}){
                                sb.append("${ans.description} (")
                                sb.append(ans.answers.findAll{it.selection==true}.collect{it.description}.join(", "))
                                sb.append("), ")
                                }else{
                                sb.append(ans.description)
                                sb.append(", ")
                                }
                                }
                                sb.delete(sb.length()-2,sb.length())
                                ansDesc.add(sb.toString())
                                }
                                else if(qnTemplate=="OPT"){
                                ansDesc.add(qn.answers.find{it.selection==true}.description)
                                }
                                else if(["TXT","TXT_CND"].contains(qnTemplate)){
                                if(qn.answers.any{["ETX_INC", "ETX_INC5M", "ETX_RET", "ETX_RET50M", "ETX_EMR45M"].contains(it.templateId)}){
                                def dollerAmount = qn.answers.find{it.selection==true}.value?:0
                                ansDesc.add(java.text.NumberFormat.getCurrencyInstance().format(new BigDecimal(dollerAmount)))
                                }else if(qn.answers.any{["ETX_RETPC"].contains(it.templateId)}){
                                ansDesc.add("${qn.answers.find{it.selection==true}.value?:0}%")
                                }else{
                                ansDesc.add(qn.answers.find{it.selection==true}.value?:0)
                                }
                                }
                                ansDesc.each{
                                def text = org.apache.commons.text.StringEscapeUtils.escapeXml10(it)
                            </gsp:scriptlet>
                            <fo:block  space-after="15px">
                                $text
                            </fo:block>
                            <gsp:scriptlet>}</gsp:scriptlet> <!-- End of Answer Loop -->
                        </fo:block> <!-- End Of Answer -->
                    </fo:block>
                    <gsp:scriptlet>}</gsp:scriptlet> <!-- End of Question Loop -->
                </fo:block>

                <!-- Action Plan -->
                <fo:block space-after="60px" >
                    <!-- For Each Action Group (i.e. dimension) -->
                    <gsp:scriptlet>
                        private def replaceFootnote(def text) {
                        if(!text){
                        return ''
                        }
                        return org.apache.commons.text.StringEscapeUtils.escapeXml10(text).replaceAll(footNoteRegToken) { fnToken, fnNo ->
                        "&lt;fo:inline font-size='12px' font-family='regular' font-style='normal' font-weight='normal' baseline-shift='super'&gt;$fnNo&lt;/fo:inline&gt;"}
                        }
                        actionGroups.each{ag->
                        def dimensionTitle =org.apache.commons.text.StringEscapeUtils.escapeXml10(ag.dimension.description)
                    </gsp:scriptlet>
                    <fo:block space-after="60px" > <!-- Action Group by Dimension -->
                        <fo:block role="H2" keep-with-next.within-page="always" padding-top="10px" padding-bottom="10px"  background-color="#EDEDED" font-size="20px"  line-height="120%">
                            <fo:inline padding-left="60px" padding-right="60px" font-family="medium" font-style="normal" font-weight="500">$dimensionTitle</fo:inline>
                        </fo:block>
                        <fo:block> <!--  Action Block -->
                            <gsp:scriptlet>
                                ag.actions.eachWithIndex{ action,index->
                                def no=index+1
                            </gsp:scriptlet>
                            <fo:block space-before="40px">
                                <fo:block role="H3" keep-with-next.within-page="always" margin="0px 60px 0px 60px" font-family="bold" font-style="normal" font-weight="bold" font-size="18px" line-height="120%"> <!-- Action Title and Description -->
                                    $no)<fo:character character="&#x20;" />
                                    <gsp:scriptlet>
                                        def newActionTitle =  replaceFootnote(action.title)
                                    </gsp:scriptlet>
                                    ${newActionTitle}
                                </fo:block>
                                <fo:block orphans="2" widows="2" margin="0px 80px 0px 80px" space-before="25px" font-size="16px" line-height="120%" line-stacking-strategy="font-height">
                                    <gsp:scriptlet>
                                        def newActionDesc =  replaceFootnote(action.description)
                                    </gsp:scriptlet>
                                    ${newActionDesc}
                                </fo:block>
                                <gsp:scriptlet>
                                    def sponsorContent = sponsorContents?.find{it.id==action.sponsorContentId}?.contents
                                    if(sponsorContent){
                                </gsp:scriptlet>
                                <fo:block margin="0px 60px 0px 60px" space-before="25px"  padding-top="20px" padding-bottom="10px" font-size="16px" background-color="#EDEDED" line-height="120%">
                                    <gsp:scriptlet>
                                        sponsorContent.each{
                                        def content= org.apache.commons.text.StringEscapeUtils.escapeXml10(it.text)
                                        def fontFamily="any"
                                        def fontStyle="normal"
                                        def fontWeight="normal"

                                        if("I"==it.styleCode){
                                        fontStyle="italic"
                                        }else if("B" == it.styleCode){
                                        fontWeight="bold"
                                        }
                                    </gsp:scriptlet>
                                    <fo:block keep-together.within-page="always"  space-after="10px" font-family="${fontFamily}" font-style="${fontStyle}" font-weight="${fontWeight}">
                                        <fo:block margin-left="20px" margin-right="20px">$content</fo:block>
                                    </fo:block>
                                    <gsp:scriptlet>}</gsp:scriptlet>
                                </fo:block>
                                <gsp:scriptlet>}</gsp:scriptlet>
                                <fo:block> <!--  Action Steps Block-->
                                    <gsp:scriptlet>
                                        action.steps.each{ step ->
                                    </gsp:scriptlet>
                                    <!-- Steps -->
                                    <fo:block role="H4" keep-with-next.within-page="always" margin="0px 80px 0px 80px" space-before="25px" font-family="bold" font-style="normal" font-weight="bold" font-size="16px" line-height="120%">
                                        <gsp:scriptlet>
                                            def newStepDesc =  replaceFootnote(step.description)
                                        </gsp:scriptlet>
                                        ${newStepDesc}
                                    </fo:block>
                                    <fo:block margin="0px 80px 0px 80px" orphans="2" widows="2" font-size="16px" line-height="120%" > <!--  Instruction & Links Block -->
                                        <fo:block  space-before="15px">
                                            <gsp:scriptlet>
                                                step.instructions.each{ instruction->
                                            </gsp:scriptlet>
                                            <fo:list-block> <!-- Instructions -->
                                                <fo:list-item>
                                                    <fo:list-item-label end-indent="label-end()">
                                                        <fo:block><fo:character character="&#x2022;" /></fo:block>
                                                    </fo:list-item-label>
                                                    <fo:list-item-body start-indent="body-start()">
                                                        <fo:block line-stacking-strategy="font-height">
                                                            <gsp:scriptlet>
                                                                def newInstruction =  replaceFootnote(instruction)
                                                            </gsp:scriptlet>
                                                            ${newInstruction}
                                                        </fo:block>
                                                    </fo:list-item-body>
                                                </fo:list-item>
                                            </fo:list-block>
                                            <gsp:scriptlet>}</gsp:scriptlet> <!-- End of Instruction Loop -->
                                        </fo:block>
                                        <gsp:scriptlet> <!-- Links Loop -->
                                            step.links.each{ link->
                                            def linkTitle = org.apache.commons.text.StringEscapeUtils.escapeXml10(link.title)
                                            def linkUrl = org.apache.commons.text.StringEscapeUtils.escapeXml10(link.url)
                                        </gsp:scriptlet>
                                        <fo:block space-before="15px" color="#0073CF" font-family="medium" font-style="normal" font-weight="500" > <!-- Links -->
                                            <fo:basic-link space-before="15px" external-destination="url(${linkUrl})" fox:alt-text="$linkTitle" show-destination="new">
                                                $linkTitle
                                            </fo:basic-link>
                                        </fo:block>
                                        <gsp:scriptlet>}</gsp:scriptlet> <!--  End of Each Link -->
                                    </fo:block> <!-- Instructions and Links Block End -->
                                    <gsp:scriptlet>}</gsp:scriptlet> <!-- End of Step -->
                                </fo:block> <!--  Action Steps Block END-->
                            </fo:block>
                            <gsp:scriptlet>}</gsp:scriptlet> <!-- End of Action Loop -->
                        </fo:block> <!--  Action Block END-->
                    </fo:block>
                    <gsp:scriptlet>}</gsp:scriptlet> <!-- End of Action Group -->
                </fo:block> <!-- End of All Actions Block-->
                <gsp:scriptlet>if(footnotes){</gsp:scriptlet>
                <fo:block margin="0px 40px 0px 40px" space-after="40px" font-size="13px" font-family="regular" font-style="normal" font-weight="normal" line-height="120%">
                    <gsp:scriptlet>
                        footnotes.eachWithIndex{id,descriptions, index ->
                        def no = index+1
                    </gsp:scriptlet>
                    <fo:block space-after="15px" keep-together.within-page="always">
                        <gsp:scriptlet>
                            descriptions.eachWithIndex{description, i ->
                            def descriptionText = org.apache.commons.text.StringEscapeUtils.escapeXml10(description)
                            if(i==0){
                        </gsp:scriptlet>
                        <fo:block>
                            $no. $descriptionText
                        </fo:block>
                        <gsp:scriptlet>}else{</gsp:scriptlet>
                        <fo:block space-before="10px">
                            $descriptionText
                        </fo:block>
                        <gsp:scriptlet>}}</gsp:scriptlet>
                    </fo:block>
                    <gsp:scriptlet>}</gsp:scriptlet>
                </fo:block>
                <gsp:scriptlet>}</gsp:scriptlet>
                <fo:footnote>
                    <fo:inline></fo:inline>
                    <fo:footnote-body>
                        <fo:block padding-top="30px" padding-bottom="40px" background-color="#EDEDED" keep-together.within-page="always">
                            <fo:block margin="0px 40px 0px 40px" font-size="16px" font-family="bold"  font-style="normal" font-weight="bold" line-height="120%">
                                <gsp:scriptlet>
                                    disclaimers.each{disclaimer->
                                    def text = org.apache.commons.text.StringEscapeUtils.escapeXml10(disclaimer)
                                </gsp:scriptlet>
                                <fo:block space-after="15px">
                                    $text
                                </fo:block>
                                <gsp:scriptlet>}</gsp:scriptlet>
                            </fo:block>

                            <fo:block font-size="16px" margin='0px 40px 0px 40px' font-family="regular" font-style="normal" font-weight="normal" line-height="120%">
                                <gsp:scriptlet>
                                    disclosuresBeforeTable.each{ para->
                                    def text =  org.apache.commons.text.StringEscapeUtils.escapeXml10(para)
                                </gsp:scriptlet>
                                <fo:block space-after="15px">
                                    $text
                                </fo:block>
                                <gsp:scriptlet>}</gsp:scriptlet>
                            </fo:block>

                            <fo:block-container display-align="center" space-after="15px" >
                                <fo:block margin="0px 40px 0px 40px" font-size="16px" font-family="bold"  font-style="normal" font-weight="bold" line-height="120%">
                                    <fo:block space-after="15px" font-family="regular">$footerContentTableTitle</fo:block>
                                    <gsp:scriptlet>
                                        def columnWidth = (1024-80)/3
                                    </gsp:scriptlet>
                                    <fo:table table-layout="fixed" border-width="2px" border-style="solid">
                                        <fo:table-column column-width="${columnWidth}" />
                                        <fo:table-column column-width="${columnWidth}" />
                                        <fo:table-column column-width="${columnWidth}" />
                                        <fo:table-body>
                                            <gsp:scriptlet>
                                                footerContentTableString.split(":").each{rowText->
                                            </gsp:scriptlet>
                                            <fo:table-row height="45px">
                                                <gsp:scriptlet>
                                                    rowText.split(",").each{cellText->
                                                </gsp:scriptlet>
                                                <fo:table-cell border-width="2px" border-style="solid" text-align="center">
                                                    <fo:block>$cellText</fo:block>
                                                </fo:table-cell>
                                                <gsp:scriptlet>}</gsp:scriptlet>
                                            </fo:table-row>
                                            <gsp:scriptlet>}</gsp:scriptlet>
                                        </fo:table-body>
                                    </fo:table>
                                </fo:block>
                            </fo:block-container>

                            <fo:block font-size="16px" margin='0px 40px 0px 40px' font-family="regular" font-style="normal" font-weight="normal" line-height="120%">
                                <gsp:scriptlet>
                                    disclosuresAfterTable.each{ para->
                                    def text =  org.apache.commons.text.StringEscapeUtils.escapeXml10(para)
                                </gsp:scriptlet>
                                <fo:block space-after="15px">
                                    $text
                                </fo:block>
                                <gsp:scriptlet>}</gsp:scriptlet>
                            </fo:block>
                        </fo:block>
                    </fo:footnote-body>
                </fo:footnote>
            </fo:block>
        </fo:flow>
    </fo:page-sequence>
</fo:root>
