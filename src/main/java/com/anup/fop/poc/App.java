package com.anup.fop.poc;

import java.io.FileOutputStream;

public class App {
    public static void main(String[] args) {
        String configFile = "/Users/manjitshakya/JavaApacheFOP-POC/src/main/resources/conf/fop.xconf";
        String outputFile = "/Users/manjitshakya/JavaApacheFOP-POC/cars.pdf";
        String dataFile = "/Users/manjitshakya/JavaApacheFOP-POC/src/main/resources/data/cars.xml";
        String styleFile = "/Users/manjitshakya/JavaApacheFOP-POC/src/main/resources/xslt/cars-template.xsl";

        PdfGenerator pdfGenerator = new PdfGenerator();

        try (FileOutputStream pdfOutput = new FileOutputStream(outputFile)) {
            pdfGenerator.createPdfFile(configFile, dataFile, styleFile, pdfOutput);
        } catch (Exception e) {
            e.printStackTrace();
        }
        System.exit(0);
    }
}
