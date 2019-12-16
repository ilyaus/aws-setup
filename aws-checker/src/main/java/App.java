import aws.AwsS3;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class App {
  private static final Logger log = LoggerFactory.getLogger(App.class);

  public static void main(String[] args) {
    new App().run(args);
  }

  private void run(String[] args) {
    log.info("Running App");

    AwsS3 awsS3 = new AwsS3("");
    awsS3.listS3Buckets();
  }

}
