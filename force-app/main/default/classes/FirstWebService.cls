@RestResource(urlMapping='/firstwebservice')
 global class FirstWebService
  {
    @HttpGet
    global static String doGet() {
        SYSTEM.debug(' @@@@@@@@@@@ Hello ');
    String name = RestContext.request.params.get('id');
    return 'your Id is ==>'+name;
    }
   }