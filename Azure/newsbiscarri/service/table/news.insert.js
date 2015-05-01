/*
function insert(item, user, request) {
    request.execute();
}
*/

var azure = require('azure');
var qs = require('querystring');
var appSettings = require('mobileservice-config').appSettings;

function insert(item, user, request) {
    // Get storage account settings from app settings.
    if (item.titulo == '')
        request.respond(500,  'Title is important!');
     
    var accountName = appSettings.STORAGE_ACCOUNT_NAME;
    var accountKey = appSettings.STORAGE_ACCOUNT_ACCESS_KEY;
    var host = accountName + '.blob.core.windows.net';
    
    // Set the BLOB store container name on the item, which must be lowercase.
    item.containerName = 'newscontainer';

    // If it does not already exist, create the container 
    // with public read access for blobs.        
    var blobService = azure.createBlobService(accountName, accountKey, host);
    blobService.createContainerIfNotExists(item.containerName, {
        publicAccessLevel: 'blob'
    }, function(error) {
        if (!error) {
            // Provide write access to the container for the next 5 mins.        
            var sharedAccessPolicy = {
                AccessPolicy: {
                    Permissions: azure.Constants.BlobConstants.SharedAccessPermissions.WRITE,
                    Expiry: new Date(new Date().getTime() + 5 * 60 * 1000)
                }
            };

            // Generate the upload URL with SAS for the new image.
            var sasQueryUrl = 
            blobService.generateSharedAccessSignature(item.containerName, 
            item.filename, sharedAccessPolicy);

            // Set the query string.
            item.sasQueryString = qs.stringify(sasQueryUrl.queryString);

            // Set the full path on the new item, 
            // which is used for data binding on the client. 
            item.imageUri = sasQueryUrl.baseUrl + sasQueryUrl.path;
            item.estado = 'NOT PUBLISHED';
            item.owner = user.userId;
            item.votes = 0;
            var d = new Date();
            item.date = d.getTime();

        } else {            
            console.error(error);
        }
        request.execute();
    });
}