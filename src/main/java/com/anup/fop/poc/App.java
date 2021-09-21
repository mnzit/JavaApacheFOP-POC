package com.anup.fop.poc;

import java.io.FileOutputStream;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class App {
    public static void main(String[] args) {
 String configFile = "/Users/manjitshakya/playground/JavaApacheFOP-POC/src/main/resources/conf/fop.xconf";
        String outputFile = "/Users/manjitshakya/playground/JavaApacheFOP-POC/cars.pdf";
        String dataFile = "/Users/manjitshakya/playground/JavaApacheFOP-POC/src/main/resources/data/cars.xml";
        String styleFile = "/Users/manjitshakya/playground/JavaApacheFOP-POC/src/main/resources/xslt/cars-template.xsl";

        PdfGenerator pdfGenerator = new PdfGenerator();

        try (FileOutputStream pdfOutput = new FileOutputStream(outputFile)) {
            pdfGenerator.createPdfFile(configFile, dataFile, styleFile, pdfOutput);
        } catch (Exception e) {
            e.printStackTrace();
        }
        System.exit(0);

    }
}
