REST is a style of web architecture, building on past successful experiences with WWW: statelessness, resource-centric, full use of HTTP and URI protocols and the provision of unified interfaces. These superior design considerations have allowed REST to become the most popular web services standard. In a sense, by emphasizing the URI and leveraging early Internet standards such as HTTP, REST has paved the way for large and scalable web applications. Currently, the support that Go has For REST is still very basic. However, by implementing custom routing rules and different request handlers for each type of HTTP request, we can achieve RESTful architecture in our Go webapps.

Most of the time, clients inform servers of state changes using HTTP. They have four operations with which to do this:
* GET is used to obtain resources 
* POSTs is used to create or update resources 
* PUT updates resources 
* DELETE deletes resources

![REST architecture](https://astaxie.gitbooks.io/build-web-application-with-golang/en/images/8.3.rest2.png?raw=true)

