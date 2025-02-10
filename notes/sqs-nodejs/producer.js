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

export const messageSend = async (sqsQueueUrl) => {
  const command = new SendMessageCommand({
    QueueUrl: sqsQueueUrl,
    DelaySeconds: 5,
    MessageAttributes: {
      Timestamp: {
        DataType: "String",
        StringValue: Date.now().toString(),
      },
    },
    MessageBody: "Hello there! Here's a timestamp: " + Date.now(),
  });

  const response = await client.send(command);
  console.log("Message Sent:", response);
  return response;
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

  for (let i = 0; i < 10; i++) {
    messageSend(SQS_QUEUE_URL);
  }
};

main();
