//
//  HPCSSwiftClient.h
//  HPCSMist
//
//  Created by Mike Hagedorn on 8/20/12.
//  © Copyright 2013 Hewlett-Packard Development Company, L.P.
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
#import <Foundation/Foundation.h>
#import "HPCSAuthorizedHTTPClient.h"

extern NSString *const HPCSSwiftContainersListDidFailNotification;
extern NSString *const HPCSSwiftContainerSaveDidFailNotification;
extern NSString *const HPCSSwiftContainerDeleteDidFailNotification;
extern NSString *const HPCSSwiftObjectSaveDidFailNotification;
extern NSString *const HPCSSwiftObjectShowDidFailNotification;
extern NSString *const HPCSSwiftObjectDeleteDidFailNotification;

extern NSString *const HPCSSwiftContainerObjectCountHeaderKey;
extern NSString *const HPCSSwiftContainerBytesUsedHeaderKey;
extern NSString *const HPCSSwiftAccountObjectCountHeaderKey;
extern NSString *const HPCSSwiftAccountBytesUsedHeaderKey;
extern NSString *const HPCSSwiftAccountContainerCountHeaderKey;

/**
   The interface to the object storage system
 */

@interface HPCSSwiftClient :  HPCSAuthorizedHTTPClient



///------------------------
/// @name Container Operations
///------------------------

/**
   Returns a list of all containers owned by the authenticated request sender

   @param success A block containing NSHTTPURLResponse from Swift and the NSArray of Containers
   @param failure A block containing NSHTTPURLResponse from Swift and the NSError.
   @return Calls either the success for failure block depending on HTTPStatus code returned
 *
 */
- (void)containers:(void ( ^)(NSHTTPURLResponse *responseObject, NSArray *records))success
           failure:(void ( ^)(NSHTTPURLResponse *responseObject, NSError *error))failure;

/**
   Creates a new container belonging to the account of the authenticated request sender.

   @param container container information, must respond to **name**
   @param saved block returning NSHTTPURLResponse from Swift
   @param failure block returning NSHTTPURLResponse from Swift and the NSError
   @return Calls either the success for failure block depending on HTTPStatus code returned

   **HTTP Status Codes**

   201 successful create

   202 if the container already existed

 */
- (void)saveContainer:(id)container success:(void ( ^)(NSHTTPURLResponse *))saved
              failure:(void ( ^)(NSHTTPURLResponse *, NSError *))failure;

/**
   Deletes the specified container.
   @param container  Object that must respond to **name**
   @param success block returning NSHTTURLResponse from Swift
   @param failure Block returning NSHTTPURLResponse and NSError
   @return Calls either the success for failure block depending on HTTPStatus code returned
   @discussion All objects in the container must be deleted before the bucket itself can be deleted.

   **HTTP Status Return Codes**

   204 success

   404 container not found

   409 container not empty
 */

- (void)deleteContainer:(id)container
                success:(void ( ^)(NSHTTPURLResponse *responseObject))success
                failure:(void ( ^)(NSHTTPURLResponse *responseObject, NSError *error))failure;

/** Gives metadata details about the given container

   @param container The container to get metadata about
   @param success Block returning an NSHTTPURLResponse with headers that contain the metadata
   @param failure Block called if this call fails

 */

- (void)headContainer:(id)container
              success:(void ( ^)(NSHTTPURLResponse *responseObject))success
              failure:(void ( ^)(NSHTTPURLResponse *responseObject, NSError *error))failure;


/** Set ACL details about a container
*  @param aclList acl string formatted like see http://docs.openstack.org/developer/swift/misc.html#id5
*  @param container The container to get metadata about (must respond to Name)
*  @param success Block returning an NSHTTPURLResponse with headers that contain the metadata
*  @param failure Block called if this call fails
*  @discussion an example ACL list for granting everybody access would be
*
*/

-(void) setContainer:(id)container
             aclList:(NSString *)aclList
            success:(void ( ^)(NSHTTPURLResponse *responseObject))success
            failure:(void ( ^)(NSHTTPURLResponse *responseObject, NSError *error))failure;


///------------------------
/// @name Object Operations
///------------------------

/**
   Lists information about the objects in a container for a user that has read access to the bucket.

   @param container Object that must respond to **name**
   @param success Block returning NSHTTPURLResponse from Swift and an NSArray of results
   @param failure Block returning NSHTTPURLResponse and NSError
   @return Calls either the success for failure block depending on HTTPStatus code returned

   **HTTP Status Return Codes**

 */

- (void)objectsForContainer:(id)container
                    success:(void ( ^)(NSHTTPURLResponse *responseObject, NSArray *records))success
                    failure:(void ( ^)(NSHTTPURLResponse *responseObject, NSError *error))failure;

/**
   Deletes the specified object.
   @param object The object to delete.  It must respond to **parent**, **parent.name** and **name**
   @param success Block returning NSHTTPURLResponse from Swift
   @param failure Block returning NSHTTPURLResponse and NSError
   @return Calls either the success for failure block depending on HTTPStatus code returned

   @discussion Once deleted, there is no method to restore or undelete an object.

   **HTTP Status Codes**

   204 is passed back if the container is empty or does not exist for the specified account.

   404 If an incorrect account is specified.
 */
- (void)deleteObject:(id)object
             success:(void ( ^)(NSHTTPURLResponse *responseObject))success
             failure:(void ( ^)(NSHTTPURLResponse *responseObject, NSError *error))failure;

/**
   Saves the specified object.

   @param object The object to save.  Must respond to  **parent**, **parent.name** and **name**
   , **mimeTypeForFile**, **data**
   @param success Block returning NSHTTPURLResponse from Swift
   @param progress Block returning the state of the upload
   @param failure Block returning NSHTTPURLResponse from Swift and NSError
   @return Calls either the success or failure block depending on HTTPStatus code returned

 */
- (void)saveObject:(id)object
           success:(void ( ^)(NSHTTPURLResponse *responseObject))success
          progress:(void ( ^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progress
           failure:(void ( ^)(NSHTTPURLResponse *responseObject, NSError *error))failure;

-(void) saveObject:(id) object
          fromStream: (NSInputStream *)stream
             success:(void ( ^)(NSHTTPURLResponse *responseObject))success
             failure:(void ( ^)(NSHTTPURLResponse *responseObject, NSError *error))failure;


- (void)putPath:(NSString *)path
     parameters:(NSDictionary *)parameters
    inputStream:(NSInputStream *) stream
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/** Sets custom metadata on an object
    @param object the object which you want the metadata on, must respond to **name** and **parent.name**
    @param  metadata NSDictionary of key value pairs with keys of the form "X-Object-Meta-<ATTRIBUTE>"
    @param success Block returning NSHTTPURLResponse from Swift
    @param failure Block returning NSHTTPURLResponse from Swift and NSError
    @discussion You cannot use the POST operation to change any of the following metadata:

- Content-Length
- ETag
- Last-Modified

To set custom metadata on an object use a header name with a prefix of X-Object-Meta-. After this prefix, you can pick any name meaningful to you. For example, X-Object-Meta-Reviewed could be used indicate that the contents of an object had been reviewed.

    NSDictionary *meta = @{ @"X-Object-Meta-Reviewed": @"true"}
    [client setObject:object metadata:meta success:^(NSHTTPURLResponse *responseObject){
      NSLog(@"metadata set");
    }
    failure:^(NSHTTPURLResponse *responseObject, NSError *error){
       NSLog(@"metadata not set");
    }

** HTTP Return Codes **

- Success 202
- Failure 404
*/

- (void)setObject:(id)object
                  metadata:(NSDictionary *)metadata
                  success :(void ( ^)(NSHTTPURLResponse *responseObject))success
                  failure :(void ( ^)(NSHTTPURLResponse *responseObject, NSError *error))failure;


/** Gets all metadata on an object, convenience version of headObject:

@param object the object which you want the metadata on, must respond to **name** and **parent.name**
@param success metadata is the NSDictionary taken from the responseObject headers result
@param failure called if there is an error


@disussion this is really an alias for headObject:success:failure:
*/
-(void)getObjectMetadata:(id)object
                 success:(void ( ^)(NSHTTPURLResponse *responseObject, NSDictionary *metadata))success
                 failure:(void ( ^)(NSHTTPURLResponse *responseObject, NSError *error))failure;


/**
   Retrieves the specified object.

   @param object The object to save.  Must respond to  **parent**, **parent.name** and **name**
   @param success Block returning NSHTTPURLResponse from Swift
   @param failure Block returning NSHTTPURLResponse from Swift and NSError

 */

- (void)getObject:(id)object
          success:(void ( ^)(NSHTTPURLResponse *responseObject, NSData *data))success
          failure:(void ( ^)(NSHTTPURLResponse *responseObject, NSError *error))failure;

/**
   Retrieves information about an object for a user with read access without fetching the object.

   @param object The object to save.  Must respond to **parent**,**parent.name**, **name**
   @param success Block returning NSHTTPURLResponse from Swift. This will be populated with information about the object in the HTTP header.   For example:

    NSHTTPURLResponse *hr = (NSHTTPURLResponse*)responseObject;
    NSDictionary *dict = [hr allHeaderFields];
    NSLog(@"HEADERS : %@",[dict description]);


   @param failure Block returning NSHTTPURLResponse from Swift and NSError
   @param success responseObject with metadata stored in httpresponse.

   @return Calls either the success or failure block depending on HTTPStatus code returned


 */
- (void)headObject:(id)object
           success:(void ( ^)(NSHTTPURLResponse *responseObject))success
           failure:(void ( ^)(NSHTTPURLResponse *responseObject, NSError *error))failure;


/**
   Adds an object to a bucket for a user that has write access to the bucket. A success response indicates the object was successfully stored; if the object already exists, it will be overwritten.
   @param data The NSData to be stored
   @param mimeType The mimeType of the resource
   @param destinationPath Dont know what this is
   @param parameters The HTTP parameters for the POST operation
   @param progress Block which takes an parameters for progress bars
   @param success  Block returning NSHTTPURLResponse from Swift.
   @param failure  Block returning NSHTTPURLResponse from Swift and NSError
 */
- (void)putObjectWithData:(NSData *)data
                 mimeType:(NSString *)mimeType
          destinationPath:(NSString *)destinationPath
               parameters:(NSDictionary *)parameters
                 progress:(void ( ^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progress
                  success:(void ( ^)(NSHTTPURLResponse *responseObject))success
                  failure:(void ( ^)(NSHTTPURLResponse *responseObject, NSError *error))failure;

/**
   Returns the full path for an object

   @param object The object to get the path of.  Must respond to **parent**,**parent.name**, **name**
   @return The NSString of the whole path to the object

 */
- (NSString *)urlForObject:(id)object;

/**
   Returns an NSDictionary of HTTP headers, usually used with a HEAD request to get object metadata

   @param response The response from an Operation

   @discussion This is a helper method to extract information from a header, typically to get
   a count of objects in the container, or bytes used, as this is more peformant than a full GET
   request

   For containers:
   X-Container-Bytes-Used,X-Container-Object-Count

   For top level container request
   X-Account-Container-Count

 */
- (NSDictionary *)metaDataFromResponse:(NSHTTPURLResponse *)response;

/**
    URL encode a string
 
    @param source the string to URLEncode
 
 */
- (NSString *) URLEncodedString:(NSString *)source;

@end
