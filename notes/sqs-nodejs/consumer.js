import {
  SQSClient,
  paginateListQueues,
  SendMessageCommand,
  ReceiveMessageCommand,
  DeleteMessageCommand,
  DeleteMessageBatchCommand,
} from "@aws-sdk/client-sqs";

// https://docs.aws.amazon.com/sdk-for-javascript/v3/developer-guide/javascript_sqs_code_examples.html

// The configuration object (`{}`) is required. If the region and credentials
// are omitted, the SDK uses your local configuration if it exists.
const client = new SQSClient({});

// Settings
// You MUST set your environment variables or hardcode values here
const queue_name = "devops";
const AWS_REGION = process.env.AWS_REGION;
const AWS_ACCOUNT_ID = process.env.AWS_ACCOUNT_ID;
const SQS_QUEUE_URL = `https://sqs.${AWS_REGION}.amazonaws.com/${AWS_ACCOUNT_ID}/${queue_name}`;

const receiveMessage = (queueUrl) => {
  return client.send(
    new ReceiveMessageCommand({
      AttributeNames: ["SentTimestamp"],
      MaxNumberOfMessages: 10,
      MessageAttributeNames: ["All"],
      QueueUrl: queueUrl,
      WaitTimeSeconds: 20,
      VisibilityTimeout: 20,
    }),
  );
};

export const waitForMessages = async (queueUrl = SQS_QUEUE_URL) => {
  console.log("Using Queue:", queueUrl);
  const { Messages } = await receiveMessage(queueUrl);

  if (!Messages) {
    console.log("No Message Timeout. Exiting...");
    return;
  }

  if (Messages.length === 1) {
    console.log("SINGLE-MESSAGE");
    console.log(Messages[0].Body);
    await client.send(
      new DeleteMessageCommand({
        QueueUrl: queueUrl,
        ReceiptHandle: Messages[0].ReceiptHandle,
      }),
    );
  } else {
    console.log("MULTI-MESSAGE", Messages.length);
    Messages.forEach((msg) => {
      console.log(msg.Body);
    });
    await client.send(
      new DeleteMessageBatchCommand({
        QueueUrl: queueUrl,
        Entries: Messages.map((message) => ({
          Id: message.MessageId,
          ReceiptHandle: message.ReceiptHandle,
        })),
      }),
    );
  }
};

export const main = async () => {
  // You can also use `ListQueuesCommand`, but to use that command you must
  // handle the pagination yourself. You can do that by sending the `ListQueuesCommand`
  // with the `NextToken` parameter from the previous request.
  const paginatedQueues = paginateListQueues({ client }, {});
  const queues = [];

  for await (const page of paginatedQueues) {
    if (page.QueueUrls?.length) {
      queues.push(...page.QueueUrls);
    }
  }

  console.log(`You have ${queues.length} queue(s) in your account.`);
  console.log(queues.map((t) => `  * ${t}`).join("\n"));

  waitForMessages(SQS_QUEUE_URL);
};

main();
