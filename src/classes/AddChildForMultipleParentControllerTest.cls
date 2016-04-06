/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData = true)
private class AddChildForMultipleParentControllerTest { 

    static testMethod void AddChildForMultipleParent_WithValidDataTest() {
      Bulk_Entry_Settings__c objSetting = populateSettingRec();
      insert objSetting;
      List<Account> listAccounts = new List<Account>();
      listAccounts = populateAccountRec(50 , 'Pune');
      PageReference pageRef = Page.AddChildForMultipleParent;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('sId',objSetting.Id);
      test.startTest();
      AddChildForMultipleParentController objController = new AddChildForMultipleParentController();
      
      objController.viewFieldSetForParentChild();
      
      objController.SearchParentRecords();
      
      Map<String, Schema.SObjectType> mapsObjectType = Schema.getGlobalDescribe();
        Schema.DescribeSObjectResult DescribeSObjectResultObj = mapsObjectType.get(objSetting.Parent_Object__c).getDescribe();
        if(DescribeSObjectResultObj.FieldSets.getMap().containsKey(objSetting.Parent_List_Field_Set__c)) {
            for(Schema.FieldSetMember objFields : DescribeSObjectResultObj.FieldSets.getMap().get(objSetting.Parent_List_Field_Set__c).getFields()) {
                if(objFields.getFieldPath().equalsIgnoreCase('BillingCity')) {
                    objController.objParentSobject.put(objFields.getFieldPath() , 'Pune');
                }
            }
        }
      objController.SearchParentRecords();
      
      //objController.showNextPage();
      //objController.showPreviousPage();
      
      for(Integer i = 0; i < objController.listTotalParentRecords.size(); i++) {
        objController.listTotalParentRecords[i].isSelected = true;
      }
      //objController.addRow();
      objController.addBlankRow();
      
      Schema.DescribeSObjectResult DescribeSObjectResultObjForChild = mapsObjectType.get(objSetting.Child_Object__c).getDescribe();
      if(DescribeSObjectResultObjForChild.FieldSets.getMap().containsKey(objSetting.Default_Settings_Field_Set__c)) {
          for(Schema.FieldSetMember objFields : DescribeSObjectResultObjForChild.FieldSets.getMap().get(objSetting.Default_Settings_Field_Set__c).getFields()) {
              if(objFields.getFieldPath().equalsIgnoreCase('LastName')) {
                  objController.objChildSobject.put(objFields.getFieldPath() , 'TestContact');
              }
              if(objFields.getFieldPath().equalsIgnoreCase('SLAExpirationDate__c')) {
                  objController.objChildSobject.put(objFields.getFieldPath() , Date.today());
              }
              if(objFields.getFieldPath().equalsIgnoreCase('NumberofLocations__c')) {
                  objController.objChildSobject.put(objFields.getFieldPath() , 5);
              }
          }
      }
      objController.addRowWithDefault();
      
      objController.IndexNumber = objController.listTotalParentRecords.size()-1;
      AddChildForMultipleParentController.readFieldSet(objSetting.Parent_Object__c,objSetting.Parent_List_Field_Set__c);
      //objController.removeChildRecord();
      objController.SaveChildRecords();
      objController.cancelSearch();
        
      test.stopTest();
      
    }
    
    static testMethod void AddChildForMultipleParent_WithoutValidDataTest() {
      AddChildForMultipleParentController objController;
      Bulk_Entry_Settings__c objSetting = populateSettingRec();
      List<Account> listAccounts = new List<Account>();
      listAccounts = populateAccountRec(4 , 'Mumbai');
      insert objSetting;
      PageReference pageRef = Page.AddChildForMultipleParent;
      Test.setCurrentPage(pageRef);
      
       /* Invalid page parameters are passed */
      ApexPages.currentPage().getParameters().put('sId','a0090000015KfWL');
      test.startTest();
      objController = new AddChildForMultipleParentController();
      objController.viewFieldSetForParentChild();
      system.assertEquals(objController.IsDataInvalid , false);
      
      /* Valid data passed with page size 4 */
      PageReference objPageRef = Page.AddChildForMultipleParent;
      Test.setCurrentPage(objPageRef);
      ApexPages.currentPage().getParameters().put('sId', objSetting.Id);
      objController = new AddChildForMultipleParentController();
      objController.viewFieldSetForParentChild();
      
      Map<String, Schema.SObjectType> mapsObjectType = Schema.getGlobalDescribe();
        Schema.DescribeSObjectResult DescribeSObjectResultObj = mapsObjectType.get(objSetting.Parent_Object__c).getDescribe();
        if(DescribeSObjectResultObj.FieldSets.getMap().containsKey(objSetting.Parent_List_Field_Set__c)) {
            for(Schema.FieldSetMember objFields : DescribeSObjectResultObj.FieldSets.getMap().get(objSetting.Parent_List_Field_Set__c).getFields()) {
                if(objFields.getFieldPath().equalsIgnoreCase('BillingCity')) {
                    objController.objParentSobject.put(objFields.getFieldPath() , 'Mumbai');
                }
            }
        }
      //objController.sortExpression='ASC';
      objController.getSortDirection();
      objController.ViewData();
      objController.getParentMap();
      objController.strStartRange = '03/02/2015';
      objController.strEndRange = '03/05/2015';
      objController.SearchParentRecords();
      objController.updatePage(2);
      objController.showNextPage();
      objController.showPreviousPage();
      //objController.addRow();
      objController.addRowWithDefault();
      
      Schema.DescribeSObjectResult DescribeSObjectResultObjForChild = mapsObjectType.get(objSetting.Child_Object__c).getDescribe();
      if(DescribeSObjectResultObjForChild.FieldSets.getMap().containsKey(objSetting.Default_Settings_Field_Set__c)) {
          for(Schema.FieldSetMember objFields : DescribeSObjectResultObjForChild.FieldSets.getMap().get(objSetting.Default_Settings_Field_Set__c).getFields()) {
              if(objFields.getFieldPath().equalsIgnoreCase('LastName')) {
                  objController.objChildSobject.put(objFields.getFieldPath() , 'TestContact');
              }
              if(objFields.getFieldPath().equalsIgnoreCase('MMG02__SLAExpirationDate__c')) {
                  objController.objChildSobject.put(objFields.getFieldPath() , system.now());
              }
              if(objFields.getFieldPath().equalsIgnoreCase('MMG02__NumberofLocations__c')) {
                  objController.objChildSobject.put(objFields.getFieldPath() , 5);
              }
          }
      } 
      
      for(Integer i = 0; i < objController.listTotalParentRecords.size(); i++) {
        objController.listTotalParentRecords[i].isSelected = true;
      }
      objController.addRow();
      objController.addBlankRow();
      objController.addRowWithDefault();
      objController.IndexNumber = 2;
      objController.removeChildRecord();
      objController.SaveChildRecords();
      objController.cancelSearch();
      
      List<Bulk_Entry_Settings__c> listSettings = new List<Bulk_Entry_Settings__c>();
      listSettings = populateSettingRecList();
      PageReference obj1PageRef = Page.AddChildForMultipleParent;
      Test.setCurrentPage(obj1PageRef);
      ApexPages.currentPage().getParameters().put('sId', listSettings[0].Id);
      objController = new AddChildForMultipleParentController();
      objController.viewFieldSetForParentChild();
      
      PageReference obj2PageRef = Page.AddChildForMultipleParentWithoutHeader;
      Test.setCurrentPage(obj2PageRef);
      ApexPages.currentPage().getParameters().put('sId', listSettings[1].Id);
      objController = new AddChildForMultipleParentController();
      objController.viewFieldSetForParentChild();
      
    }
    
    private static List<Bulk_Entry_Settings__c> populateSettingRecList(){
        List<Bulk_Entry_Settings__c> listSetting = new List<Bulk_Entry_Settings__c>();
        
        Bulk_Entry_Settings__c objSetting  = new Bulk_Entry_Settings__c();
        objSetting.Child_Object__c = 'Contac';
        objSetting.Child_Record_List_Field_Set__c = 'Contact_FieldS';
        objSetting.Default_options_section_Title__c ='Default Settings';
        objSetting.Child_Record_List_Title__c = 'Child Records';
        objSetting.Default_Settings_Field_Set__c = 'TestDefaultContac';
        objSetting.Lookup_Relationship_field__c = 'AccountI';
        objSetting.Search_Section_Title__c = 'Search Criteria';
        objSetting.Record_Selection_Title__c = 'Record Selection';
        objSetting.Parent_Object__c = 'Accont';
        objSetting.Search_Criteria_Field_Set__c = 'SearchAccount_FieldSe';
        objSetting.Parent_List_Field_Set__c = 'TestAccout';
        listSetting.add(objSetting);
        
        Bulk_Entry_Settings__c objSetting1  = new Bulk_Entry_Settings__c();
        objSetting1.Child_Object__c = 'Contact';
        objSetting1.Child_Record_List_Field_Set__c = 'Contact_FieldS';
        objSetting1.Default_options_section_Title__c ='Default Settings';
        objSetting1.Child_Record_List_Title__c = 'Child Records';
        //objSetting1.Default_Settings_Field_Set__c = 'TestDefaultContac';
        objSetting1.Lookup_Relationship_field__c = 'AccountI';
        objSetting1.Search_Section_Title__c = 'Search Criteria';
        objSetting1.Record_Selection_Title__c = 'Record Selection';
        objSetting1.Parent_Object__c = 'Account';
        //objSetting1.Search_Criteria_Field_Set__c = 'SearchAccount_FieldSe';
        objSetting1.Parent_List_Field_Set__c = 'MMG02__TestAccout';
        objSetting1.Cancel_URL_Link__c = 'https://ap1.salesforce.com/home/home.jsp';
        listSetting.add(objSetting1);
        insert listSetting;
        return listSetting;
    }
    
    
    private static Bulk_Entry_Settings__c populateSettingRec(){
        Bulk_Entry_Settings__c objSetting  = new Bulk_Entry_Settings__c();
        objSetting.Child_Object__c = 'Contact';
        objSetting.Child_Record_List_Field_Set__c = 'MMG02__Contact_FieldSet';
        objSetting.Default_options_section_Title__c ='Default Settings';
        objSetting.Child_Record_List_Title__c = 'Child Records';
        objSetting.Default_Settings_Field_Set__c = 'MMG02__TestDefaultContact';
        objSetting.Lookup_Relationship_field__c = 'AccountId';
        objSetting.Search_Section_Title__c = 'Search Criteria';
        objSetting.Record_Selection_Title__c = 'Record Selection';
        objSetting.Parent_Object__c = 'Account';
        objSetting.Search_Criteria_Field_Set__c = 'MMG02__SearchAccount_FieldSet';
        objSetting.Parent_List_Field_Set__c = 'MMG02__Account_FieldSet';
        objSetting.Default_Record_Size__c = '10';
        objSetting.Cancel_URL_Link__c = 'https://ap1.salesforce.com/home/home.jsp';
        objSetting.Include_Range_Search__c = true;
        return objSetting; 
    }
    
    private static List<Account> populateAccountRec(Integer recordCount , String strCity){
        List<Account> listAccount = new List<Account>(); 
        Account objAccount;
        for(Integer i = 0; i < recordCount; i++) {
            objAccount = new Account();
            objAccount.Name = 'Test Account'+i;
            objAccount.Active__c = 'Yes';
            objAccount.BillingCity = strCity;
            listAccount.add(objAccount);
        }
        insert listAccount;
        return listAccount; 
    }
    
    private static void getFields(AddChildForMultipleParentController objController, Bulk_Entry_Settings__c objSettings) {
        Map<String, Schema.SObjectType> mapsObjectType = Schema.getGlobalDescribe();
        Schema.DescribeSObjectResult DescribeSObjectResultObj = mapsObjectType.get(objSettings.Parent_Object__c).getDescribe();
        if(DescribeSObjectResultObj.FieldSets.getMap().containsKey(objSettings.Parent_List_Field_Set__c)) {
            for(Schema.FieldSetMember objFields : DescribeSObjectResultObj.FieldSets.getMap().get(objSettings.Parent_List_Field_Set__c).getFields()) {
                if(objFields.getFieldPath().equalsIgnoreCase('BillingCity')) {
                    objController.objParentSobject.put(objFields.getFieldPath() , 'Pune');
                }
            }
        }
    }
}