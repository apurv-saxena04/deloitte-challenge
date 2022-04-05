@isTest
public class Test_SurveyControllerHandler {
	
    @testSetup static void setup() {
        
        //Creating Lead record
        Lead lead = new Lead();
        lead.Company = 'Test Lead';
        lead.LastName = 'Lead Last Name';
		lead.Status = 'Open';
        lead.Email = 'testleadone@test.com';
    	insert lead;
        
        //Creating Contact record
        Contact con = new Contact();
        con.FirstName = 'Test Contact';
        con.LastName = 'Lead Last Name';
        con.Email = 'testconone@test.com';   
    	insert con;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
    }
    
    @isTest static void testSurveyResultSuccess() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            			EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            			LocaleSidKey='en_US', ProfileId = p.Id, 
            			TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@deloitte.com');
        System.runAs(u){
            String email = 'test.one@gmail.com';
        	String payload = '[{"firstName":"test","lastName":"one","email":"test.one@gmail.com","customerType":"New","userId":"'+UserInfo.getUserId()+'","comment":"asdasd"}]';   
            test.startTest();
            SurveyControllerHandler.createSurveyResult(payload,email);
            test.stopTest();
        }        
    }
    
    @isTest static void testSurveyResultfailure() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            			EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            			LocaleSidKey='en_US', ProfileId = p.Id, 
            			TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@deloitte.com');
        System.runAs(u){
            String email = 'testleadone@test.com';
        	String payload = '[{"firstName":"test","lastName":"one","email":"testleadone@test.com","customerType":"New","userId":"'+UserInfo.getUserId()+'","comment":"asdasd"}]';   
            test.startTest();
            SurveyControllerHandler.createSurveyResult(payload,email);
            test.stopTest();
        }        
    }
}