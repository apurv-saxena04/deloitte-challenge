/************************************************************************************************
* @Name         SurveyControllerHandler 
* @Author       Apurv Saxena <apurv93@gmail.com>
* @Date         29/03/2022
* @Group        Apex Class
* @Description  This Apex class includes @AuraEnabled methods which is referred salesRepSurvey.js
                The class checks for Duplicate Lead/Contact records with matching email address
                captured via duplicate rules set up in the org and links the survey result to it. 
                In case if no Duplicate Lead/Contact records are found, 
*************************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Apurv           29/03/2022          Initial Creation                                                      
*************************************************************************************************/

public with sharing class SurveyControllerHandler {
    
    @AuraEnabled
    public static string createSurveyResult(String payload, String email) {

        List<Lead> leadListToInsert = new List<Lead>();
        List<Survey_Result__c> srListToInsert = new List<Survey_Result__c>();
        List<payloadWrapper> payloadWrapperList = (List<payloadWrapper>)JSON.deserialize(payload,List<payloadWrapper>.class);
        
        //Utilizing SOSL query to find matching records from Lead/Contact using a single query
        String searchquery='FIND\''+email+'\'IN EMAIL FIELDS RETURNING Lead(Id,Name LIMIT 1), Contact(Id,Name LIMIT 1)'; 
        List<List<SObject>> matchingRecord = search.query(searchquery);
        System.debug('matchingRecord---->'+matchingRecord);

        Lead[] matchedLead = (Lead[])matchingRecord[0];
        Contact[] matchedContact = (Contact[])matchingRecord[1];

        if(matchedLead.size() > 0){
            srListToInsert = insertSurveyResult(payload, matchedLead[0].Id);
            if(srListToInsert.size()>0){
                try{
                    insert srListToInsert;
                    return 'Survey Record entered successfully !!';
                }catch(Exception ex){
                    system.debug('Error while inserting survey record--->'+ ex.getMessage());
                    throw new AuraHandledException(ex.getMessage());
                }
            }
        }else if(matchedContact.size()>0){

            srListToInsert = insertSurveyResult(payload, matchedContact[0].Id);
            if(srListToInsert.size()>0){
                try{
                    insert srListToInsert;
                    return 'Survey Record entered successfully !!';
                }catch(Exception ex){
                    system.debug('Error while inserting survey record--->'+ ex.getMessage());
                    throw new AuraHandledException(ex.getMessage());
                }
            }
        }else{
            
            //Creating lead record
            for(payloadWrapper survey : payloadWrapperList){
                Lead lead = new Lead();
                lead.FirstName = survey.firstName;
                lead.LastName = survey.lastName;
                lead.Email = survey.email;
                lead.Company = survey.firstName + ' ' + survey.lastName + ' Company';
                leadListToInsert.add(lead);
            }

            if(leadListToInsert.size() > 0){
                try{
                    insert leadListToInsert;
                    srListToInsert = insertSurveyResult(payload, leadListToInsert[0].Id);
                    if(srListToInsert.size()>0){
                        insert srListToInsert;
                    }
                }catch(Exception ex){
                    system.debug('Error while inserting Lead record--->'+ ex.getMessage());
                    throw new AuraHandledException(ex.getMessage());
                }
            }          
        }

        return null;
    }

    public static List<Survey_Result__c> insertSurveyResult(String payload, Id parentId){
        system.debug('parentID--->'+parentId);
        List<Survey_Result__c> srList = new List<Survey_Result__c>();
        List<payloadWrapper> payloadWrapperList = (List<payloadWrapper>)JSON.deserialize(payload,List<payloadWrapper>.class);
        String objName = parentId.getSObjectType().getDescribe().getName();
        for(payloadWrapper survey : payloadWrapperList){
            Survey_Result__c sr = new Survey_Result__c();
            sr.First_Name__c = survey.firstName;
            sr.Last_Name__c = survey.lastName;
            sr.Comments__c = survey.comment;
            sr.Sales_Rep__c = survey.userId;
            sr.Email_Address__c = survey.email;
            sr.Rating__c = survey.rating;
            sr.Customer_Type__c = survey.customerType;
            if(objName == 'Contact'){
                sr.Contact__c = parentId;
            }else{
                sr.Lead__c = parentId;
            }        
            srList.add(sr);
            system.debug('srList--->'+srList);
        }
        if(srList.size()>0){
            return srList;
        }
        
        return null;
    }

    //Wrapper class to capture all the elements from payload
    public class payloadWrapper {
        @AuraEnabled public string firstName{get; set;}
        @AuraEnabled public string lastName{get; set;}
        @AuraEnabled public string email{get; set;}
        @AuraEnabled public string customerType{get; set;}
        @AuraEnabled public integer rating{get; set;}
        @AuraEnabled public string userId{get; set;}
        @AuraEnabled public string comment{get; set;}
    }
}