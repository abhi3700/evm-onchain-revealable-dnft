/* 
    Get metadata & image 
*/

const base64EncodedJson =
  "data:application/json;base64,eyJuYW1lIjogIlNQMDAxIiwiZGVzY3JpcHRpb24iOiJTdG9yeSBQcm90b2NvbCBNeXN0ZXJ5IEJveCBORlQiLCJpbWFnZSI6ICI8c3ZnIHdpZHRoPVwiODAwcHhcIiBoZWlnaHQ9XCI4MDBweFwiIHZpZXdCb3g9XCIwIDAgMjQgMjRcIiB4bWxucz1cImh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnXCIgZmlsbD1cIiNGNDgwMjRcIiBzdHJva2U9XCIjMDAwMDAwXCIgc3Ryb2tlLXdpZHRoPVwiMVwiIHN0cm9rZS1saW5lY2FwPVwicm91bmRcIiBzdHJva2UtbGluZWpvaW49XCJtaXRlclwiPjxwb2x5Z29uIHBvaW50cz1cIjMgMTYgMyA4IDEyIDE0IDIxIDggMjEgMTYgMTIgMjIgMyAxNlwiIHN0cm9rZS13aWR0aD1cIjBcIiBvcGFjaXR5PVwiMC4xXCIgZmlsbD1cIiMwNTljZjdcIj48L3BvbHlnb24+PHBvbHlnb24gcG9pbnRzPVwiMjEgOCAyMSAxNiAxMiAyMiAzIDE2IDMgOCAxMiAyIDIxIDhcIj48L3BvbHlnb24+PHBvbHlsaW5lIHBvaW50cz1cIjMgOCAxMiAxNCAxMiAyMlwiIHN0cm9rZS1saW5lY2FwPVwicm91bmRcIj48L3BvbHlsaW5lPjxsaW5lIHgxPVwiMjFcIiB5MT1cIjhcIiB4Mj1cIjEyXCIgeTI9XCIxNFwiIHN0cm9rZS1saW5lY2FwPVwicm91bmRcIj48L2xpbmU+PC9zdmc+IiwiYXR0cmlidXRlcyI6IFt7InRyYWl0X3R5cGUiOiAiU2hhcGUiLCJ2YWx1ZSI6ICJDdWJlIn0seyJ0cmFpdF90eXBlIjogIkJvcmRlcnMiLCJ2YWx1ZSI6ICJCbGFjayJ9LHsidHJhaXRfdHlwZSI6ICJGaWxsZWQiLCJ2YWx1ZSI6ICJPcmFuZ2UifV19";

const jsonPrefix = "data:application/json;base64,";
const base64Data = base64EncodedJson.substring(jsonPrefix.length);
const jsonString = Buffer.from(base64Data, "base64").toString("utf-8");
const jsonString1 = `{
  "name": "SP001",
  "description": "Story Protocol Mystery Box NFT",
  "image": "<svg width=\\"800px\\" height=\\"800px\\" viewBox=\\"0 0 24 24\\" xmlns=\\"http://www.w3.org/2000/svg\\" fill=\\"#F48024\\" stroke=\\"#000000\\" stroke-width=\\"1\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"miter\\"><polygon points=\\"3 16 3 8 12 14 21 8 21 16 12 22 3 16\\" stroke-width=\\"0\\" opacity=\\"0.1\\" fill=\\"#059cf7\\"></polygon><polygon points=\\"21 8 21 16 12 22 3 16 3 8 12 2 21 8\\"></polygon><polyline points=\\"3 8 12 14 12 22\\" stroke-linecap=\\"round\\"></polyline><line x1=\\"21\\" y1=\\"8\\" x2=\\"12\\" y2=\\"14\\" stroke-linecap=\\"round\\"></line></svg>",
  "attributes": [
    {
      "trait_type": "Shape",
      "value": "Cube"
    },
    {
      "trait_type": "Borders",
      "value": "Black"
    },
    {
      "trait_type": "Filled",
      "value": "Orange"
    }
  ]
}`;

const jsonData = JSON.parse(jsonString1);
console.log("Metadata: \n", jsonData, "\n====");
console.log("Metadata's image svg data: \n", jsonData["image"]);
