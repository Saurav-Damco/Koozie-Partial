///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@isTest(seealldata = true)
private class testcqClarificationHandler {

    static testMethod void cqQuestionHandler() {        
  
        
        test.starttest();
        List<string> CaseId = new List<string>();
        
        List<User> runUser = new List<User>
            ([Select ID 
              From User
              Where isActive = True 
              And Profile.Name like '%BIC%'
              And (Not Profile.Name like '%claim%')
              And (Not Profile.Name like '%customer service%')
              And (Not Profile.Name like '%Administrator%')
              And (Not Profile.Name like '%read only%')]);

        system.runas(runUser[0]){
        
            List<RecordType> rtList = 
                [Select ID, Name 
                From RecordType 
                Where Name in('ClarificationQuestion')];
                
            RecordType r1 = new RecordType();
            
            For(RecordType rtLoop : rtList ){
                r1 = (rtLoop.Name == 'ClarificationQuestion') ? rtLoop : r1;
            }
            
            Group g = [select Id from Group where Type = 'Queue' and DeveloperName = 'Clarification_Pending'];
            
            DateTime dtNow = system.Now().addMinutes(-5);
            
            Account a = new Account(Name = 'AccountTest');
            insert a;  
            
            RecordType rt = [Select ID from RecordType Where Name = 'Clarification' and sObjectType = 'Case'];  
            
            Contact cont = new Contact();
            cont.firstname = 'Jack';
            cont.lastname = 'Frost';  
            cont.Email = 'hello@goodbye.com';
            cont.AccountId = a.Id;
            insert cont;
             

            Case ClarificationCase = new Case(ContactID = cont.id, 
            Status = 'New', Origin = 'Phone', Clarification_Description__c ='Hello Dolly', 
            Clarification_to_email__c ='hello@goodbye.com', Proof_Description__c ='Hello Dolly', 
            Proof_to_email__c ='hello@goodbye.com', 
            Current_Process__c = 'Initial Email', Last_Clarification_Created_Date__c = dtNow,
            clarification_cc_email__c = 'to@me.com', proof_CC_email__c= 'tom@me.com', RecordTypeID = rt.ID);
            insert ClarificationCase;     
            
            Clarification_Question__c cqClari= new Clarification_Question__c(Case__c = ClarificationCase.Id, RecordTypeId=r1.ID, 
            Status__c = 'Open', Message_Text__c = 'Welcome to the party',Line_number__c = '1', Question_Type__c='Clarification');
            insert cqClari;
            

            List<ID> lstClarificationCase = new List<ID>();
            lstClarificationCase.add(ClarificationCase.ID);
            
            ClarificationCase.Status = 'Day 3 Call';
            ClarificationCase.OwnerID = g.ID;    
            ClarificationCase.Cadence_Owner_Change__c = true;
            update ClarificationCase;

            System.schedule('testQueHander03', '0 55 * * * ?', new scheduledClarificationHandler()); 

        }
        
        test.stopTest();
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////