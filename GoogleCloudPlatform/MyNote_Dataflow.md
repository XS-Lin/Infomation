# GoogleCloudPlatform Note #

## Flex Template ##

[training-data-analyst dataflow](https://github.com/GoogleCloudPlatform/training-data-analyst/tree/master/quests/dataflow)
[skill boost flex template](https://www.cloudskillsboost.google/paths/655/course_templates/264/labs/438164?locale=ja)

### Create flex template ###

1. Source Code

    ~~~java
        public static PipelineResult run(Options options) {
            Pipeline pipeline = Pipeline.create(options);
            options.setJobName("my-pipeline-" + System.currentTimeMillis());
            /*
             * Steps:
             * 1) Read something
             * 2) Transform something
             * 3) Write something
             */
            pipeline.apply("ReadFromGCS", TextIO.read().from(input))
                    .apply("ParseJson", ParDo.of(new JsonToCommonLog()))
                    .apply("WriteToBQ",
                            BigQueryIO.<CommonLog>write().to(output).useBeamSchema()
                                    .withWriteDisposition(BigQueryIO.Write.WriteDisposition.WRITE_TRUNCATE)
                                    .withCreateDisposition(BigQueryIO.Write.CreateDisposition.CREATE_IF_NEEDED));
            LOG.info("Building pipeline...");
            return pipeline.run();
    ~~~

1. Build JAR

    ~~~powershell
    cd $BASE_DIR
    mvn clean package
    ~~~

1. Create Dockerfile

    ~~~dockerfile
    FROM gcr.io/dataflow-templates-base/java11-template-launcher-base:latest
    
    ENV FLEX_TEMPLATE_JAVA_MAIN_CLASS="YOUR-CLASS-HERE"
    ENV FLEX_TEMPLATE_JAVA_CLASSPATH="/template/pipeline.jar"
    
    COPY target/YOUR-JAR-HERE.jar ${FLEX_TEMPLATE_JAVA_CLASSPATH}
    ~~~

1. Build Image

    ~~~powershell
    gcloud config set builds/use_kaniko True # キャッシュを有効
    gcloud builds submit --tag "gcr.io/$PROJECT_ID/my-pipeline:latest" .
    ~~~

1. Create Matadata file

    ~~~json
    {
      "name": "My Branching Pipeline",
      "description": "A branching pipeline that writes raw to GCS Coldline, and filtered data to BQ",
      "parameters": [
        {
          "name": "inputPath",
          "label": "Input file path.",
          "helpText": "Path to events.json file.",
          "regexes": [
            ".*\\.json"
          ]
        },
        {
          "name": "outputPath",
          "label": "Output file location",
          "helpText": "GCS Coldline Bucket location for raw data",
          "regexes": [
            "gs:\\/\\/[a-zA-z0-9\\-\\_\\/]+"
          ]
        },
        {
          "name": "tableName",
          "label": "BigQuery output table",
          "helpText": "BigQuery table spec to write to, in the form 'project:dataset.table'.",
          "regexes": [
            "[^:]+:[^.]+[.].+"
          ]
        }
      ]
    }
    ~~~

1. Submit

    ~~~powershell
    gcloud beta dataflow flex-template run ${JOB_NAME} \
      --region=$REGION \
      --template-file-gcs-location ${TEMPLATE_LOC} \
      --parameters "inputPath=${INPUT_PATH},outputPath=${OUTPUT_PATH},tableName=${BQ_TABLE}"
    ~~~
