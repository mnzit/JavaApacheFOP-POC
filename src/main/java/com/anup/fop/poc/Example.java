package com.anup.fop.poc;

import groovy.text.XmlTemplateEngine;
import org.xml.sax.SAXException;

import javax.xml.parsers.ParserConfigurationException;
import java.io.IOException;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Example {
    public static void main(String[] args) throws ParserConfigurationException, SAXException, IOException, ClassNotFoundException {
        final String regex = "<a[^>]+href=\\'(.*?)\\'[^>]*>(.*?)<\\/a>";
        String string = "Download and save this <a href='https://go.ml.com/lbd26url' target='_blank' data-bactmln='action-AC200002-step121link0'>budget and debt management worksheet</a> and <a href='https://go.ml.com/lbd26url2' target='_blank' data-bactmln='action-AC200002-step121link0'>budget and debt management worksheet2</a> to set up your budget and monitor your progress.";

        final Pattern pattern = Pattern.compile(regex, Pattern.MULTILINE);
        final Matcher matcher = pattern.matcher(string);

        List<String> values = new ArrayList<>();
        Map<String, AchorTag> links= new HashMap<>();


        while (matcher.find()) {
            String url = matcher.group(0);
//            System.out.println("Full match: " + matcher.group(0));

            AchorTag achorTag = new AchorTag();
            for (int i = 1; i <= matcher.groupCount(); i++) {

//                System.out.println("Group " + i + ": " + matcher.group(i));

                values.add(matcher.group(i));

                if(i==1){
                    achorTag.setLink(matcher.group(i));
                }else{
                    achorTag.setTitle(matcher.group(i));
                }
            }

            links.put(url,achorTag);
        }

        Iterator entries = links.entrySet().iterator();
        while (entries.hasNext()) {
            Map.Entry thisEntry = (Map.Entry) entries.next();
            String key = (String) thisEntry.getKey();
            AchorTag value = (AchorTag) thisEntry.getValue();
            String template = "<fo:basic-link external-destination=\"url('%s')\" color=\"blue\" text-decoration=\"underline\">%s</fo:basic-link>";
            string = string.replace(key, String.format(template,value.getLink(),value.getTitle()));

        }

        System.out.println(string);

    }

    static class AchorTag{
        private String link;
        private String title;

        public AchorTag(String link, String title) {
            this.link = link;
            this.title = title;
        }

        public AchorTag() {
        }

        public String getLink() {
            return link;
        }

        public void setLink(String link) {
            this.link = link;
        }

        public String getTitle() {
            return title;
        }

        public void setTitle(String title) {
            this.title = title;
        }

        @Override
        public String toString() {
            return "AchorTag{" +
                    "link='" + link + '\'' +
                    ", title='" + title + '\'' +
                    '}';
        }
    }
}