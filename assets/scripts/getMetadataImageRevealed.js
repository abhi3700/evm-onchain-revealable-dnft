/* 
    Get metadata & image

    View output by running on CLI: `$ node getMetadataImage.js` in `scripts/` folder.
*/

// 1. put the tokenURI output here
const base64EncodedJson =
  "data:application/json;base64,eyJuYW1lIjogIm5mdCAxAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIiwiZGVzY3JpcHRpb24iOiAiZ29vZCBuZnQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAiLCJpbWFnZSI6ICI8c3ZnIHZpZXdCb3g9XCIwIDAgNTggNThcIiBzdHlsZT1cImVuYWJsZS1iYWNrZ3JvdW5kOm5ldyAwIDAgNTggNTg7XCIgeG1sOnNwYWNlPVwicHJlc2VydmVcIj48Zz48cGF0aCBzdHlsZT1cImZpbGw6O1wiIGQ9XCJNMjkuMzkyLDU0Ljk5OWMxMS4yNDYsMC4xNTYsMTcuNTItNC4zODEsMjEuMDA4LTkuMTg5YzMuNjAzLTQuOTY2LDQuNzY0LTExLjI4MywzLjY0Ny0xNy4zMjMgQzUwLjAwNCw2LjY0MiwyOS4zOTIsNi44MjcsMjkuMzkyLDYuODI3UzguNzgxLDYuNjQyLDQuNzM4LDI4LjQ4OGMtMS4xMTgsNi4wNCwwLjA0NCwxMi4zNTYsMy42NDcsMTcuMzIzIEMxMS44NzIsNTAuNjE4LDE4LjE0Niw1NS4xNTUsMjkuMzkyLDU0Ljk5OXpcIi8+PHBhdGggc3R5bGU9XCJmaWxsOiNGOUE2NzE7XCIgZD1cIk00LjQ5OSwzMC4xMjVjLTAuNDUzLTAuNDI5LTAuOTg1LTAuNjg3LTEuNTU5LTAuNjg3QzEuMzE2LDI5LjQzOCwwLDMxLjQxOSwwLDMzLjg2MiBjMCwyLjQ0MywxLjMxNiw0LjQyNCwyLjkzOSw0LjQyNGMwLjY4NywwLDEuMzExLTAuMzcsMS44MTEtMC45NjRDNC4yOTcsMzQuOTcsNC4yMTgsMzIuNTM4LDQuNDk5LDMwLjEyNXpcIi8+PHBhdGggc3R5bGU9XCJmaWxsOiNGOUE2NzE7XCIgZD1cIk01Ny44MjMsMjYuMjk4Yy0wLjU2My0yLjM3Ny0yLjMtMy45OTktMy44NzktMy42MjJjLTAuNDkxLDAuMTE3LTAuODk4LDAuNDMtMS4yMjUsMC44NTUgYzAuNTM4LDEuNTE1LDAuOTk0LDMuMTU0LDEuMzI4LDQuOTU3YzAuMTU1LDAuODM3LDAuMjYxLDEuNjc5LDAuMzI4LDIuNTIyYzAuNTIsMC4yODQsMS4wNzIsMC40MDIsMS42MDgsMC4yNzQgQzU3LjU2MiwzMC45MDgsNTguMzg2LDI4LjY3NSw1Ny44MjMsMjYuMjk4elwiLz48cGF0aCBzdHlsZT1cImZpbGw6O1wiIGQ9XCJNMTMuOSwxNi45OThjLTAuMjU2LDAtMC41MTItMC4wOTgtMC43MDctMC4yOTNsLTUtNWMtMC4zOTEtMC4zOTEtMC4zOTEtMS4wMjMsMC0xLjQxNCBzMS4wMjMtMC4zOTEsMS40MTQsMGw1LDVjMC4zOTEsMC4zOTEsMC4zOTEsMS4wMjMsMCwxLjQxNEMxNC40MTIsMTYuOTAxLDE0LjE1NiwxNi45OTgsMTMuOSwxNi45OTh6XCIvPjxwYXRoIHN0eWxlPVwiZmlsbDo7XCIgZD1cIk0xNi45MDEsMTMuOTk4Yy0wLjM2NywwLTAuNzItMC4yMDItMC44OTYtMC41NTNsLTMtNmMtMC4yNDctMC40OTQtMC4wNDctMS4wOTUsMC40NDctMS4zNDIgYzAuNDk1LTAuMjQ1LDEuMDk0LTAuMDQ3LDEuMzQyLDAuNDQ3bDMsNmMwLjI0NywwLjQ5NCwwLjA0NywxLjA5NS0wLjQ0NywxLjM0MkMxNy4yMDQsMTMuOTY0LDE3LjA1MiwxMy45OTgsMTYuOTAxLDEzLjk5OHpcIi8+PHBhdGggc3R5bGU9XCJmaWxsOjtcIiBkPVwiTTIwLjksMTEuOTk4Yy0wLjQxOSwwLTAuODA5LTAuMjY1LTAuOTQ4LTAuNjg0bC0yLTZjLTAuMTc1LTAuNTI0LDAuMTA4LTEuMDkxLDAuNjMyLTEuMjY1IGMwLjUyNy0wLjE3NiwxLjA5MSwwLjEwOCwxLjI2NSwwLjYzMmwyLDZjMC4xNzUsMC41MjQtMC4xMDgsMS4wOTEtMC42MzIsMS4yNjVDMjEuMTExLDExLjk4MiwyMS4wMDUsMTEuOTk4LDIwLjksMTEuOTk4elwiLz48cGF0aCBzdHlsZT1cImZpbGw6O1wiIGQ9XCJNMjUuODk5LDEwLjk5OGMtMC40OCwwLTAuOTA0LTAuMzQ3LTAuOTg1LTAuODM2bC0xLTZjLTAuMDkxLTAuNTQ0LDAuMjc3LTEuMDYsMC44MjItMS4xNSBjMC41NDMtMC4wOTgsMS4wNjEsMC4yNzcsMS4xNSwwLjgyMmwxLDZjMC4wOTEsMC41NDQtMC4yNzcsMS4wNi0wLjgyMiwxLjE1QzI2LjAwOSwxMC45OTUsMjUuOTU0LDEwLjk5OCwyNS44OTksMTAuOTk4elwiLz48cGF0aCBzdHlsZT1cImZpbGw6O1wiIGQ9XCJNMjkuOSwxMC45OThjLTAuNTUzLDAtMS0wLjQ0Ny0xLTF2LTZjMC0wLjU1MywwLjQ0Ny0xLDEtMXMxLDAuNDQ3LDEsMXY2IEMzMC45LDEwLjU1MSwzMC40NTMsMTAuOTk4LDI5LjksMTAuOTk4elwiLz48cGF0aCBzdHlsZT1cImZpbGw6O1wiIGQ9XCJNMzMuOSwxMC45OThjLTAuMTA0LDAtMC4yMTEtMC4wMTctMC4zMTYtMC4wNTJjLTAuNTIzLTAuMTc0LTAuODA3LTAuNzQtMC42MzItMS4yNjVsMi02IGMwLjE3NS0wLjUyMywwLjczNi0wLjgwOSwxLjI2NS0wLjYzMmMwLjUyMywwLjE3NCwwLjgwNywwLjc0LDAuNjMyLDEuMjY1bC0yLDZDMzQuNzA5LDEwLjczNCwzNC4zMTksMTAuOTk4LDMzLjksMTAuOTk4elwiLz48cGF0aCBzdHlsZT1cImZpbGw6O1wiIGQ9XCJNMzcuOSwxMS45OThjLTAuMTA0LDAtMC4yMTEtMC4wMTctMC4zMTYtMC4wNTJjLTAuNTIzLTAuMTc0LTAuODA3LTAuNzQtMC42MzItMS4yNjVsMi02YzAuMTc1LTAuNTIzLDAuNzM3LTAuODA4LDEuMjY1LTAuNjMyYzAuNTIzLDAuMTc0LDAuODA3LDAuNzQsMC42MzIsMS4yNjVsLTIsNkMzOC43MDksMTEuNzM0LDM4LjMxOSwxMS45OTgsMzcuOSwxMS45OTh6XCIvPjxwYXRoIHN0eWxlPVwiZmlsbDo7XCIgZD1cIk00MC44OTksMTMuOTk4Yy0wLjE1LDAtMC4zMDMtMC4wMzQtMC40NDYtMC4xMDVjLTAuNDk0LTAuMjQ3LTAuNjk0LTAuODQ4LTAuNDQ3LTEuMzQybDMtNmMwLjI0OC0wLjQ5NCwwLjg0OC0wLjY5MiwxLjM0Mi0wLjQ0N2MwLjQ5NCwwLjI0NywwLjY5NCwwLjg0OCwwLjQ0NywxLjM0MmwtMyw2QzQxLjYxOSwxMy43OTYsNDEuMjY3LDEzLjk5OCw0MC44OTksMTMuOTk4elwiLz48Y2lyY2xlIHN0eWxlPVwiZmlsbDojRkZGRkZGO1wiIGN4PVwiMjJcIiBjeT1cIjI2LjAwM1wiIHI9XCI2XCIvPjxjaXJjbGUgc3R5bGU9XCJmaWxsOiNGRkZGRkY7XCIgY3g9XCIzNlwiIGN5PVwiMjYuMDAzXCIgcj1cIjhcIi8+PGNpcmNsZSBzdHlsZT1cImZpbGw6O1wiIGN4PVwiMjJcIiBjeT1cIjI2LjAwM1wiIHI9XCIyXCIvPjxjaXJjbGUgc3R5bGU9XCJmaWxsOjtcIiBjeD1cIjM2XCIgY3k9XCIyNi4wMDNcIiByPVwiM1wiLz48cGF0aCBzdHlsZT1cImZpbGw6O1wiIGQ9XCJNMjguMjI5LDUwLjAwOWMtMy4zMzYsMC02LjY0Ni0wLjgwNC05LjY5MS0yLjM5MmMtMC40OS0wLjI1NS0wLjY4LTAuODU5LTAuNDI1LTEuMzQ5IGMwLjI1NS0wLjQ5LDAuODU2LTAuNjgyLDEuMzQ5LTAuNDI1YzQuNTA1LDIuMzQ4LDkuNjQ4LDIuODAyLDE0LjQ4NywxLjI4YzQuODM5LTEuNTIyLDguNzk2LTQuODQyLDExLjE0NC05LjM0NiBjMC4yNTUtMC40OTEsMC44NTctMC42ODQsMS4zNDktMC40MjVjMC40OSwwLjI1NSwwLjY4LDAuODU5LDAuNDI1LDEuMzQ5Yy0yLjU5NSw0Ljk3OS02Ljk2OSw4LjY0Ni0xMi4zMTYsMTAuMzI5IEMzMi40NzQsNDkuNjg1LDMwLjM0Niw1MC4wMDksMjguMjI5LDUwLjAwOXpcIi8+PHBhdGggc3R5bGU9XCJmaWxsOjtcIiBkPVwiTTE4LDUwLjAwM2MtMC41NTMsMC0xLTAuNDQ3LTEtMWMwLTIuNzU3LDIuMjQzLTUsNS01YzAuNTUzLDAsMSwwLjQ0NywxLDFzLTAuNDQ3LDEtMSwxIGMtMS42NTQsMC0zLDEuMzQ2LTMsM0MxOSw0OS41NTYsMTguNTUzLDUwLjAwMywxOCw1MC4wMDN6XCIvPjxwYXRoIHN0eWxlPVwiZmlsbDo7XCIgZD1cIk00OCw0Mi4wMDNjLTAuNTUzLDAtMS0wLjQ0Ny0xLTFjMC0xLjY1NC0xLjM0Ni0zLTMtM2MtMC41NTMsMC0xLTAuNDQ3LTEtMXMwLjQ0Ny0xLDEtMSBjMi43NTcsMCw1LDIuMjQzLDUsNUM0OSw0MS41NTYsNDguNTUzLDQyLjAwMyw0OCw0Mi4wMDN6XCIvPjwvZz48L3N2Zz4iLCJhdHRyaWJ1dGVzIjogW3sidHJhaXRfdHlwZSI6ICJFeWVzIiwgInZhbHVlIjogIiJ9LHsidHJhaXRfdHlwZSI6ICJIYWlyIiwgInZhbHVlIjogIiJ9LHsidHJhaXRfdHlwZSI6ICJOb3NlIiwgInZhbHVlIjogIiJ9LHsidHJhaXRfdHlwZSI6ICJNb3V0aCIsICJ2YWx1ZSI6ICIifV19";

const jsonPrefix = "data:application/json;base64,";
const base64Data = base64EncodedJson.substring(jsonPrefix.length);
const jsonString = Buffer.from(base64Data, "base64").toString("utf-8");
// 2. get json string
console.log(jsonString);
/* 
/// Valid JSON -->

{"name": "nft 1","description": "good nft","image": "<svg viewBox=\"0 0 58 58\" style=\"enable-background:new 0 0 58 58;\" xml:space=\"preserve\"><g><path style=\"fill:;\" d=\"M29.392,54.999c11.246,0.156,17.52-4.381,21.008-9.189c3.603-4.966,4.764-11.283,3.647-17.323 C50.004,6.642,29.392,6.827,29.392,6.827S8.781,6.642,4.738,28.488c-1.118,6.04,0.044,12.356,3.647,17.323 C11.872,50.618,18.146,55.155,29.392,54.999z\"/><path style=\"fill:#F9A671;\" d=\"M4.499,30.125c-0.453-0.429-0.985-0.687-1.559-0.687C1.316,29.438,0,31.419,0,33.862 c0,2.443,1.316,4.424,2.939,4.424c0.687,0,1.311-0.37,1.811-0.964C4.297,34.97,4.218,32.538,4.499,30.125z\"/><path style=\"fill:#F9A671;\" d=\"M57.823,26.298c-0.563-2.377-2.3-3.999-3.879-3.622c-0.491,0.117-0.898,0.43-1.225,0.855 c0.538,1.515,0.994,3.154,1.328,4.957c0.155,0.837,0.261,1.679,0.328,2.522c0.52,0.284,1.072,0.402,1.608,0.274 C57.562,30.908,58.386,28.675,57.823,26.298z\"/><path style=\"fill:;\" d=\"M13.9,16.998c-0.256,0-0.512-0.098-0.707-0.293l-5-5c-0.391-0.391-0.391-1.023,0-1.414 s1.023-0.391,1.414,0l5,5c0.391,0.391,0.391,1.023,0,1.414C14.412,16.901,14.156,16.998,13.9,16.998z\"/><path style=\"fill:;\" d=\"M16.901,13.998c-0.367,0-0.72-0.202-0.896-0.553l-3-6c-0.247-0.494-0.047-1.095,0.447-1.342 c0.495-0.245,1.094-0.047,1.342,0.447l3,6c0.247,0.494,0.047,1.095-0.447,1.342C17.204,13.964,17.052,13.998,16.901,13.998z\"/><path style=\"fill:;\" d=\"M20.9,11.998c-0.419,0-0.809-0.265-0.948-0.684l-2-6c-0.175-0.524,0.108-1.091,0.632-1.265 c0.527-0.176,1.091,0.108,1.265,0.632l2,6c0.175,0.524-0.108,1.091-0.632,1.265C21.111,11.982,21.005,11.998,20.9,11.998z\"/><path style=\"fill:;\" d=\"M25.899,10.998c-0.48,0-0.904-0.347-0.985-0.836l-1-6c-0.091-0.544,0.277-1.06,0.822-1.15 c0.543-0.098,1.061,0.277,1.15,0.822l1,6c0.091,0.544-0.277,1.06-0.822,1.15C26.009,10.995,25.954,10.998,25.899,10.998z\"/><path style=\"fill:;\" d=\"M29.9,10.998c-0.553,0-1-0.447-1-1v-6c0-0.553,0.447-1,1-1s1,0.447,1,1v6 C30.9,10.551,30.453,10.998,29.9,10.998z\"/><path style=\"fill:;\" d=\"M33.9,10.998c-0.104,0-0.211-0.017-0.316-0.052c-0.523-0.174-0.807-0.74-0.632-1.265l2-6 c0.175-0.523,0.736-0.809,1.265-0.632c0.523,0.174,0.807,0.74,0.632,1.265l-2,6C34.709,10.734,34.319,10.998,33.9,10.998z\"/><path style=\"fill:;\" d=\"M37.9,11.998c-0.104,0-0.211-0.017-0.316-0.052c-0.523-0.174-0.807-0.74-0.632-1.265l2-6c0.175-0.523,0.737-0.808,1.265-0.632c0.523,0.174,0.807,0.74,0.632,1.265l-2,6C38.709,11.734,38.319,11.998,37.9,11.998z\"/><path style=\"fill:;\" d=\"M40.899,13.998c-0.15,0-0.303-0.034-0.446-0.105c-0.494-0.247-0.694-0.848-0.447-1.342l3-6c0.248-0.494,0.848-0.692,1.342-0.447c0.494,0.247,0.694,0.848,0.447,1.342l-3,6C41.619,13.796,41.267,13.998,40.899,13.998z\"/><circle style=\"fill:#FFFFFF;\" cx=\"22\" cy=\"26.003\" r=\"6\"/><circle style=\"fill:#FFFFFF;\" cx=\"36\" cy=\"26.003\" r=\"8\"/><circle style=\"fill:;\" cx=\"22\" cy=\"26.003\" r=\"2\"/><circle style=\"fill:;\" cx=\"36\" cy=\"26.003\" r=\"3\"/><path style=\"fill:;\" d=\"M28.229,50.009c-3.336,0-6.646-0.804-9.691-2.392c-0.49-0.255-0.68-0.859-0.425-1.349 c0.255-0.49,0.856-0.682,1.349-0.425c4.505,2.348,9.648,2.802,14.487,1.28c4.839-1.522,8.796-4.842,11.144-9.346 c0.255-0.491,0.857-0.684,1.349-0.425c0.49,0.255,0.68,0.859,0.425,1.349c-2.595,4.979-6.969,8.646-12.316,10.329 C32.474,49.685,30.346,50.009,28.229,50.009z\"/><path style=\"fill:;\" d=\"M18,50.003c-0.553,0-1-0.447-1-1c0-2.757,2.243-5,5-5c0.553,0,1,0.447,1,1s-0.447,1-1,1 c-1.654,0-3,1.346-3,3C19,49.556,18.553,50.003,18,50.003z\"/><path style=\"fill:;\" d=\"M48,42.003c-0.553,0-1-0.447-1-1c0-1.654-1.346-3-3-3c-0.553,0-1-0.447-1-1s0.447-1,1-1 c2.757,0,5,2.243,5,5C49,41.556,48.553,42.003,48,42.003z\"/></g></svg>","attributes": [{"trait_type": "Eyes", "value": ""},{"trait_type": "Hair", "value": ""},{"trait_type": "Nose", "value": ""},{"trait_type": "Mouth", "value": ""}]}
*/

// 3. json string into JSON
// TODO: need to debug why it fails inspite of correct JSON validation
// JSON Validator tool: https://jsonformatter.curiousconcept.com/#
// const jsonData = JSON.parse(jsonString);

// 4. JSON to image
// then after JSON format, then take the image
// using `jsonData["image"]`, replace '\"' with '"' and then read SVG.

// 5. read image & show on marketplace
