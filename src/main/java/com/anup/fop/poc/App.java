package com.anup.fop.poc;

import java.io.FileOutputStream;

public class App {
    public static void main(String[] args) {
        String configFile = "D:\\AnupProjects\\fop-example\\src\\main\\resources\\conf\\fop.xconf";
        String outputFile = "D:\\AnupProjects\\fop-example\\cars.pdf";
        String dataFile = "D:\\AnupProjects\\fop-example\\src\\main\\resources\\data\\cars.xml";
        String styleFile = "D:\\AnupProjects\\fop-example\\src\\main\\resources\\xslt\\cars-template.xsl";

        PdfGenerator pdfGenerator = new PdfGenerator();

        try (FileOutputStream pdfOutput = new FileOutputStream(outputFile)) {
            pdfGenerator.createPdfFile(configFile, dataFile, styleFile, pdfOutput);
        } catch (Exception e) {
            e.printStackTrace();
        }
        System.exit(0);
    }
}
