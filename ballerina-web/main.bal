// import ballerina/http;
// import ballerina/io;

// // import ballerina/langlib/strings;

// // Define the service
// service /chat on new http:Listener(8080) {

//     resource function post sendMessage(http:Caller caller, http:Request req) returns error? {
//         // Receive the user message
//         json payloadJson = check req.getJsonPayload();
//         string userMessage = (check payloadJson.userMessage).toString();

//         // Call the Python script via HTTP request
//         string pythonApiUrl = "http://localhost:5000/chatbot"; // Change this URL if necessary

//         // Prepare the request to send to the Python chatbot
//         json payload = {"message": userMessage};
//         http:Client pythonClient = check new (pythonApiUrl);
//         io:println("Sending message to Python chatbot: " + userMessage);
//         http:Response response = check pythonClient->post("/chatbot", payload);

//         // Return the response from the Python chatbot
//         json responseBody = check response.getJsonPayload();
//         check caller->respond(responseBody);
//     }
// }
import ballerina/http;
import ballerina/io;
@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowHeaders: ["Content-Type"],
        allowMethods: ["GET", "POST", "OPTIONS"]
    }
}
//core configure

// Define the service
service /chatbot on new http:Listener(8080) {

    // Resource function to handle POST requests to the /chatbot endpoint
    resource function post . (http:Caller caller, http:Request req) returns error? {
        // Retrieve the message from the request payload
        json payload = check req.getJsonPayload();
        string message = (check payload.message).toString(); // Get the user's message
        io:println("Sending message to Python chatbot: " + message);

        // Call the Python server with the message and get the response
        json response = (check  callPythonChatbot(message)).toString(); 
        io:println("response: " , response);

        // Send the response back to the client
        check caller->respond(response);
    }
}

// Function to call the Python chatbot



function callPythonChatbot(string message) returns json|error {
    // Define the Python chatbot API URL
    string pythonApiUrl = "http://localhost:5000";
    json payload = { "message": message }; // Prepare the request payload

    // Create a new HTTP client for the Python API
    http:Client pythonClient = check new (pythonApiUrl);
    
    // Log the payload to verify what is being sent
    io:println("Sending payload to Python chatbot: ", payload.toString());
    
    // Send a POST request to the Python chatbot
    http:Response response = check pythonClient->post("/chatbot", payload);

    // Log the entire response body as a string to see if it's valid JSON or not
    string responseBody = check response.getTextPayload();
    // io:println("Raw response from Python chatbot: ", responseBody);

    // Check if the response is JSON. If not, log an error message.
    json jsonResponse;
    if response.getContentType() == "application/json" {
        // Parse the response to JSON only if it's of type application/json
        jsonResponse = check response.getJsonPayload();
    } else {
        io:println("Error: Received a non-JSON response from the Python server.");
        return error("Non-JSON response: " + responseBody);
    }

    return jsonResponse;
}


