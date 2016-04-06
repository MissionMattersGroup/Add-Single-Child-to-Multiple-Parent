public with sharing class DummyPageActionRegionControllerTesting {

    private static final String NAME = 'Name';
    private static final String SETTING_ID = 'sId';
    private static final String COMMA = ',';
    private static final String SPACE = ' ';
    private static final String STR_SELECT = 'Select';
    private static final String ID = 'id';
    private static final String STR_BLANK = '';
    private static final String STR_FROM = 'From';
    private static final String STR_WHERE = 'Where';
    private static final String STR_AND = 'AND';
    private static final String STR_QUOTE = '\'';
    private static final String STR_EQUAL = '=';
    
    public Account objAccount {get; set;}
    public Contact objContact {get; set;}
    public Bulk_Entry_Settings__c objSettings {get; set;}
    public sObject objParentSobject {get; set;}
    public sObject objChildSobject {get; set;}
    
    public String strTitle {get; set;}
    public String strSubtitle {get; set;}
    public Boolean isChildRecordSectionVisible {get; set;}
    public Boolean isBtnDisabled {get; set;}
    public Boolean isVisible {get; set;}
    public Integer IndexNumber {get; set;}
    public Boolean isVisiblePrevious {get; set;}
    public Boolean isVisibleNext {get; set;}
    public Boolean IsDataInvalid {get; set;}
    public Boolean hasStandardField ;
    public Integer pageNumber;
    public Id objSettingsId;
    public Map<string,String> strChildId;
    public List<Schema.FieldSetMember> listParentFieldMember {get; set;}
    public List<Schema.FieldSetMember> listParentSearchFieldMember {get; set;}
    public List<Schema.FieldSetMember> listDefaultFieldMember {get; set;}
    public List<Schema.FieldSetMember> listChildSelectionFieldMember{get; set;}
    public List<Schema.FieldSetMember> listChildFieldMember {get; set;} 
    public List<sObject> listChildRecords {get; set;}
    public List<ParentWrapper> listParentRecords {get; set;}
    public Database.Saveresult[] arraySaveResult {get; set;}
    public List<ChildWrapper> listWrapperChildRecordsToInsert {get; set;}
    public List<ParentWrapper> listTotalParentRecords;
    public List<ParentSearchFieldsWrapper> listParentSearchFields {get; set;}
    
    public Map<String , Boolean> mapChildFieldSets ;
    public Map<Integer , Paginator> mapPaginator;
    
    /* Constructor */
    
    public DummyPageActionRegionControllerTesting() {
        listChildRecords = new List<sObject>();
        hasStandardField = false; 
        isVisible = false;
        IsDataInvalid = true;
        isChildRecordSectionVisible = false;
        listWrapperChildRecordsToInsert = new List<ChildWrapper>();
        listParentRecords = new List<ParentWrapper>();
        listTotalParentRecords = new List<ParentWrapper>();
        listParentSearchFields = new List<ParentSearchFieldsWrapper>();
        strChildId = Apexpages.currentPage().getParameters();
        system.debug('strChildId*********'+ strChildId );
    }
    
    /* Method to set up data on page load */
    
    public void viewFieldSetForParentChild() {
        isVisible = true;
        isBtnDisabled = true;
        objSettings = new Bulk_Entry_Settings__c(); 
        try {
            objSettingsId = ApexPages.currentPage().getParameters().get(SETTING_ID);
            objSettings = [Select s.Search_Section_Title__c, 
                                  s.Search_Criteria_Field_Set__c, 
                                  s.Record_Selection_Title__c, 
                                  s.Parent_Object__c, 
                                  s.Parent_List_Field_Set__c, 
                                  s.Name, 
                                  s.Lookup_Relationship_field__c, 
                                  s.Id, 
                                  s.Default_options_section_Title__c, 
                                  s.Default_Settings_Field_Set__c, 
                                  s.Child_Record_List_Title__c, 
                                  s.Child_Record_List_Field_Set__c, 
                                  s.Child_Object__c 
                           From Bulk_Entry_Settings__c s 
                           where s.Id =: objSettingsId];
                           
            
            Map<String, Schema.SObjectType> mapsObjectType = Schema.getGlobalDescribe();
            objParentSobject = (mapsObjectType.containsKey(objSettings.Parent_Object__c)) ? Schema.getGlobalDescribe().get(objSettings.Parent_Object__c).newSObject() : NULL;
            if(objParentSobject != NULL) {
                Schema.DescribeSObjectResult DescribeSObjectResultObj = mapsObjectType.get(objSettings.Parent_Object__c).getDescribe();
                strSubtitle = DescribeSObjectResultObj.getLabel();
                strTitle = 'Add ' + objSettings.Child_Object__c + ' for for Multiple';
                for(Schema.SObjectField sObjField : DescribeSObjectResultObj.fields.getMap().values()) {
                    if(sObjField.getDescribe().getName().equalsIgnoreCase(NAME)) {
                        hasStandardField = true;
                    }
                }
                
                if(objSettings.Parent_List_Field_Set__c != NULL && DescribeSObjectResultObj.FieldSets.getMap().containsKey(objSettings.Parent_List_Field_Set__c)) {
                    Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(objSettings.Parent_List_Field_Set__c);
                    listParentFieldMember = new List<Schema.FieldSetMember>();
                    listParentFieldMember.addAll(fieldSetObj.getFields());
                    showErrorOnParentFieldSelected(listParentFieldMember , objSettings.Parent_List_Field_Set__c);
                }
                else {
                    if(objSettings.Parent_List_Field_Set__c == NULL) {
                        displayErrorMessage('Default Fieldset Not Specified for '+objSettings.Parent_Object__c);
                    }
                    else {
                        displayErrorMessage('Fieldset doesnot exist for '+ objSettings.Parent_Object__c + ' : '+ objSettings.Parent_List_Field_Set__c);
                    }
                    
                }
                if(objSettings.Search_Criteria_Field_Set__c != NULL && DescribeSObjectResultObj.FieldSets.getMap().containsKey(objSettings.Search_Criteria_Field_Set__c)) {
                    Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(objSettings.Search_Criteria_Field_Set__c);
                    listParentSearchFieldMember = new List<Schema.FieldSetMember>();
                    listParentSearchFieldMember.addAll(fieldSetObj.getFields());
                    
                    for(Schema.FieldSetMember searchField : listParentSearchFieldMember) {
                        if(strChildId.containsKey(searchField.getFieldPath()))
                        {
                            system.debug('Field is present*****************');
                            objParentSobject.put(searchField.getFieldPath(),strChildId.get(searchField.getFieldPath()));
                        }
                        listParentSearchFields.add(new ParentSearchFieldsWrapper(searchField.getFieldPath() , listParentSearchFields.size()));
                    }
                    system.debug('listParentSearchFields--------------------------'+listParentSearchFields);
                    showErrorOnParentFieldSelected(listParentSearchFieldMember , objSettings.Search_Criteria_Field_Set__c);
                }
                else {
                    if(objSettings.Search_Criteria_Field_Set__c == NULL) {
                        displayErrorMessage('Search Fieldset not Specified for '+objSettings.Parent_Object__c);
                    }
                    else {
                        displayErrorMessage('Fieldset does not exist for '+ objSettings.Parent_Object__c + ' : '+ objSettings.Search_Criteria_Field_Set__c);
                    }
                }
            }
            else {
                displayErrorMessage('Object '+objSettings.Parent_Object__c + ' doesnot exist.');
            }
            
            objChildSobject = (mapsObjectType.containsKey(objSettings.Child_Object__c)) ? Schema.getGlobalDescribe().get(objSettings.Child_Object__c).newSObject() : NULL;
            if(objChildSobject != NULL) {
                Schema.DescribeSObjectResult DescribeSObjectResultObjForChild = mapsObjectType.get(objSettings.Child_Object__c).getDescribe();
                strTitle = 'Add ' + DescribeSObjectResultObjForChild.getLabel() + ' for for Multiple';
                Map<String , Schema.SObjectField> mapChildsObjectFields = new Map<String , Schema.SObjectField>();
                mapChildsObjectFields = DescribeSObjectResultObjForChild.fields.getMap();
                
                if(objSettings.Lookup_Relationship_field__c != NULL) {
                    if(mapChildsObjectFields.containsKey(objSettings.Lookup_Relationship_field__c.toLowerCase())) {
                        Schema.SObjectField childsObjectField = mapChildsObjectFields.get(objSettings.Lookup_Relationship_field__c.toLowerCase());
                        if(!(childsObjectField.getDescribe().getType() == Schema.Displaytype.Reference)) {
                            displayErrorMessage('Invalid field type for relationship ' + objSettings.Parent_Object__c + '. Expected : ' + Schema.Displaytype.Reference + ' Actual : '+ childsObjectField.getDescribe().getType());
                        }
                        else if(childsObjectField.getDescribe().getReferenceTo().size() > 1) {
                            Map<String , Schema.Sobjecttype> mapReferenceObjects = new Map<String , Schema.Sobjecttype>();
                            for(Integer i = 0; i < childsObjectField.getDescribe().getReferenceTo().size(); i++ ) {
                                mapReferenceObjects.put(String.valueOf(childsObjectField.getDescribe().getReferenceTo().get(i)) , childsObjectField.getDescribe().getReferenceTo().get(i));
                            }
                            if(!mapReferenceObjects.containsKey(objSettings.Parent_Object__c)) {
                                displayErrorMessage('Invalid reference field '+ objSettings.Lookup_Relationship_field__c + ' for relationship ' + objSettings.Parent_Object__c);
                            }
                        }
                        else if(!String.valueOf(childsObjectField.getDescribe().getReferenceTo().get(0)).equalsIgnoreCase(objSettings.Parent_Object__c) ) {
                            displayErrorMessage('Invalid reference field '+ objSettings.Lookup_Relationship_field__c + ' for relationship ' + objSettings.Parent_Object__c);
                        }
                    }
                    else {
                        displayErrorMessage('Lookup relationship field '+ objSettings.Lookup_Relationship_field__c + ' does not exist on ' + objSettings.Child_Object__c);
                    }
                }
                else {
                    displayErrorMessage('Lookup relationship field not specified on Settings object.');
                }
                
                if(objSettings.Default_Settings_Field_Set__c != NULL && DescribeSObjectResultObjForChild.FieldSets.getMap().containsKey(objSettings.Default_Settings_Field_Set__c) ) {
                    Schema.FieldSet fieldSetObjForChild = DescribeSObjectResultObjForChild.FieldSets.getMap().get(objSettings.Default_Settings_Field_Set__c);
                    listDefaultFieldMember = new List<Schema.FieldSetMember>();
                    listDefaultFieldMember.addAll(fieldSetObjForChild.getFields());
                    showErrorOnParentFieldSelected(listDefaultFieldMember , objSettings.Default_Settings_Field_Set__c);
                    
                }
                else {
                    if(objSettings.Default_Settings_Field_Set__c == NULL) {
                        displayErrorMessage('Default Fieldset Not Specified for '+objSettings.Child_Object__c);
                    }
                    else {
                        displayErrorMessage('Fieldset does not exist for '+objSettings.Child_Object__c + ' : '+objSettings.Default_Settings_Field_Set__c);
                    }
                }
                
                if(objSettings.Child_Record_List_Field_Set__c != NULL && DescribeSObjectResultObjForChild.FieldSets.getMap().containsKey(objSettings.Child_Record_List_Field_Set__c) ) {
                    Schema.FieldSet fieldSetObjForChild = DescribeSObjectResultObjForChild.FieldSets.getMap().get(objSettings.Child_Record_List_Field_Set__c);
                    listChildSelectionFieldMember = new List<Schema.FieldSetMember>();
                    listChildSelectionFieldMember.addAll(fieldSetObjForChild.getFields());
                    showErrorOnParentFieldSelected(listChildSelectionFieldMember , objSettings.Child_Record_List_Field_Set__c);
                }
                else {
                    if(objSettings.Child_Record_List_Field_Set__c == NULL) {
                        displayErrorMessage('Default Fieldset Not Specified for '+objSettings.Child_Object__c);
                    }
                    else {
                        displayErrorMessage('Fieldset does not exist for '+objSettings.Child_Object__c + ' : '+objSettings.Child_Record_List_Field_Set__c);
                    }
                }
            }
            else {
                displayErrorMessage('Object '+objSettings.Child_Object__c + ' does not exist.');
            }
        }
        catch(Exception e) {
            displayErrorMessage(e.getMessage());
        }
    }
    
    public void showErrorOnParentFieldSelected(List<Schema.FieldSetMember> listDefaultFieldMember , String strFieldSet) {
        for(Schema.FieldSetMember objFieldSetMember : listDefaultFieldMember) {
            if(objFieldSetMember.getFieldPath().contains('.') && objFieldSetMember.getFieldPath().contains(objSettings.Parent_Object__c)) {
                displayErrorMessage('Invalid field selected : <b>'+objFieldSetMember.getLabel()+'</b> in <b>'+strFieldSet+'</b>');
            }           
        }
    }
    
    public void displayErrorMessage(String strMessage) {
        IsDataInvalid = false;
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR , strMessage);
        ApexPages.addMessage(myMsg);
    }
    
    /*public void getMapOfFieldSet() {
        mapChildFieldSets = new Map<String , Boolean>();
        for(Schema.FieldSetMember objFieldSetMember : listDefaultFieldMember) {
            
            mapChildFieldSets.put(objFieldSetMember.getFieldPath() , false);
        }
    }*/
    
    /* Method to fetch parent records based on search criteria */
    
    public void SearchParentRecords() {
        listWrapperChildRecordsToInsert = new List<ChildWrapper>();
        listChildRecords = new List<sObject>();
        isChildRecordSectionVisible = false;
        isVisible = false;
        
        List<sObject> listTempRecords = new List<sObject>();
        Boolean isFilterCondition = false;
        String strQuery = STR_SELECT + SPACE + ID + COMMA + SPACE;
        if(hasStandardField) {
            strQuery = strQuery + NAME + COMMA + SPACE; 
        }
        if(listParentFieldMember != NULL && listParentFieldMember.size() > 0) {
            for(Schema.FieldSetMember strParentField : listParentFieldMember) {
                if(strParentField.getFieldPath() != ID) {
                    strQuery = strQuery + strParentField.getFieldPath() + COMMA + SPACE;
                    if(objParentSobject.get(strParentField.getFieldPath()) != null && objParentSobject.get(strParentField.getFieldPath()) != STR_BLANK && !isFilterCondition) {
                        isFilterCondition = true;
                    }
                }
            }
        }
        strQuery = strQuery.removeEnd(COMMA + SPACE);
        strQuery += SPACE + STR_FROM + SPACE + objSettings.Parent_Object__c;
        if(isFilterCondition) {
            strQuery += SPACE + STR_WHERE + SPACE;
            for(Schema.FieldSetMember strParentField : listParentSearchFieldMember) {
                if(objParentSobject.get(strParentField.getFieldPath()) != NULL && objParentSobject.get(strParentField.getFieldPath()) != STR_BLANK) {
                    strQuery  += strParentField.getFieldPath() + SPACE + STR_EQUAL + SPACE ; 
                    if(strParentField.getType() == Schema.Displaytype.Date) {
                        //String strDate = dtatetime.
                        String strDate = DateTime.newInstance(Date.valueOf(objParentSobject.get(strParentField.getFieldPath())), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
                        strQuery  += strDate + SPACE + STR_AND + SPACE;
                    }
                    else if(strParentField.getType() == Schema.Displaytype.DateTime) {
                        String strDateTime = DateTime.valueOf(objParentSobject.get(strParentField.getFieldPath())).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                        strQuery  +=  STR_QUOTE + strDateTime +STR_QUOTE + SPACE + STR_AND + SPACE;
                    }
                    else if(strParentField.getType() == Schema.Displaytype.Double || strParentField.getType() == Schema.Displaytype.Integer) {
                        strQuery  += objParentSobject.get(strParentField.getFieldPath()) + SPACE + STR_AND + SPACE;
                    }
                    else {
                        strQuery  +=  STR_QUOTE + String.valueOf(objParentSobject.get(strParentField.getFieldPath())) +STR_QUOTE + SPACE + STR_AND + SPACE;
                    }
                }
            }
            strQuery = strQuery.removeEnd(STR_AND + SPACE);
            listTempRecords = Database.query(strQuery);
            if(listTempRecords == null && listTempRecords.size() == 0) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR , Label.NO_RECORDS_FOUND);
                ApexPages.addMessage(myMsg);
            }
            else {
                listTotalParentRecords = new List<ParentWrapper>();
                for(sObject objParent : listTempRecords) {
                    listTotalParentRecords.add(new ParentWrapper(objParent , false , String.valueOf(objParent.get(NAME))));
                }
                isBtnDisabled = false;
                PaginateParentRecods(listTotalParentRecords);
            }
            system.debug('listTotalParentRecords-----------------------'+listTotalParentRecords.size());
        }
        else {
            listParentRecords = new List<ParentWrapper>();
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR , Label.SPECIFY_SEARCH_CRITERIA);
            ApexPages.addMessage(myMsg);
        }
    }
    
    /* Method to create map of page numbers and list of Paginator records for Pagination. */
    
    public void PaginateParentRecods(List<ParentWrapper> listTotalParentRecord) {
        
        mapPaginator = new Map<Integer , Paginator>();
        Integer PageCount = 0, i = 0, j = 0;
        Integer PageSize = 10;
        Integer TotalPages = listTotalParentRecord.size() / PageSize;
        Integer lastPageSize =  math.mod(listTotalParentRecord.size() , PageSize);
        listParentRecords = new List<ParentWrapper>();
        List<ParentWrapper> listTempParent = new List<ParentWrapper>();
        if(listTotalParentRecord != NULL && listTotalParentRecord.size() > 0) {
            for(ParentWrapper sObjParent : listTotalParentRecord) {
                listTempParent.add(sObjParent);
                i++;
                if(TotalPages > 0) {
                    if(i == PageSize) {
                        j++;
                        if(mapPaginator != NULL && mapPaginator.size() == 0) {
                            mapPaginator.put(j , new Paginator(listTempParent, false, true));
                            listParentRecords.addAll(listTempParent);
                            isVisiblePrevious = false;
                            isVisibleNext = (TotalPages == 1 && lastPageSize == 0)?false : true;
                            pageNumber = j;
                        }
                        else {
                            Paginator objPaginator = (j == TotalPages)? new Paginator(listTempParent, true, false) :  new Paginator(listTempParent, true, true);
                            mapPaginator.put(j , objPaginator);
                        }
                        listTempParent = new List<ParentWrapper>();
                        i = 0;
                        PageCount++; 
                    }
                    else if((PageCount == TotalPages) && (lastPageSize != 0) && (i == lastPageSize)) {
                        j++;
                        mapPaginator.put(j , new Paginator(listTempParent, true, false));
                        listTempParent = new List<ParentWrapper>();
                        i = 0;
                        PageCount++;
                        TotalPages++;
                    }
                }
                else if(TotalPages == 0 && i == lastPageSize) {
                    j++;
                    mapPaginator.put(j , new Paginator(listTempParent, false, false));
                    listParentRecords.addAll(listTempParent);
                    isVisiblePrevious = false;
                    isVisibleNext = false;
                    pageNumber = j;
                }
            }
        }
        else {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR , Label.NO_RECORDS_FOUND);
            ApexPages.addMessage(myMsg);
        }
    }
    
    /* Method to show next page if present */
    
    public void showNextPage() {
        updatePage(++pageNumber);
    }
    
    /* Method to show previous page if present */
    
    public void showPreviousPage() {
        updatePage(--pageNumber);
    }
    
    public void updatePage(Integer intPageNumber) {
        if(mapPaginator.containsKey(intPageNumber)) {
            listParentRecords = new List<ParentWrapper>();
            listParentRecords.addAll(mapPaginator.get(intPageNumber).listPageRecords);
            isVisiblePrevious = mapPaginator.get(intPageNumber).isActivePrevious;
            isVisibleNext = mapPaginator.get(intPageNumber).isActiveNext;
        }
    } 
    
     /* Method to add child sObject rows */
    
    public void addRow() {
        
        Integer intCountRecordsNotSelected = 0;
        listWrapperChildRecordsToInsert = new List<ChildWrapper>();
        isChildRecordSectionVisible = true;
        if(listTotalParentRecords != NULL && listTotalParentRecords.size() > 0) {
            for(ParentWrapper objParentWrapper : listTotalParentRecords) {
                if(objParentWrapper.isSelected) {
                    sObject objChildSobjectToInsert = Schema.getGlobalDescribe().get(objSettings.Child_Object__c).newSObject();
                    objChildSobjectToInsert.put(objSettings.Lookup_Relationship_field__c , objParentWrapper.sObjParent.get(ID));
                    listWrapperChildRecordsToInsert.add(new ChildWrapper(objChildSobjectToInsert , mapChildFieldSets , listWrapperChildRecordsToInsert.size()));
                }
                else {
                    intCountRecordsNotSelected++;
                }
            }
            if(intCountRecordsNotSelected == listTotalParentRecords.size()) {
                isVisible = false;
                isChildRecordSectionVisible = false;
                String strMassage = 'Please select atleast one '+ objSettings.Parent_Object__c + ' record from Records Selection section.';
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR , strMassage);
                ApexPages.addMessage(myMsg);
            }
        }
    }
    
    public void showValues() {
         system.debug('objChildSobject Inside showValues------------------------------'+objChildSobject);
    }
    
    /* Method to add child sObject rows with default values */
    
    public void addRowWithDefault() {
        //addRow();
        Integer intCountRecordsNotSelected = 0;
        listWrapperChildRecordsToInsert = new List<ChildWrapper>();
        isChildRecordSectionVisible = true;
        system.debug('objChildSobject------------------------------'+objChildSobject);
        if(listTotalParentRecords != NULL && listTotalParentRecords.size() > 0) {
            for(ParentWrapper objParentWrapper : listTotalParentRecords) {
                if(objParentWrapper.isSelected) {
                    sObject objChildSobjectToInsert = Schema.getGlobalDescribe().get(objSettings.Child_Object__c).newSObject();
                    objChildSobjectToInsert.put(objSettings.Lookup_Relationship_field__c , objParentWrapper.sObjParent.get(ID));
                    for(Schema.FieldSetMember objFieldSetMember : listDefaultFieldMember) {
                        system.debug('Get field type values---------------'+objChildSobject.get(objFieldSetMember.getFieldPath()));
                        objChildSobjectToInsert.put(objFieldSetMember.getFieldPath() , objChildSobject.get(objFieldSetMember.getFieldPath()));
                    }
                           
                    listWrapperChildRecordsToInsert.add(new ChildWrapper(objChildSobjectToInsert , mapChildFieldSets , listWrapperChildRecordsToInsert.size()));
                }
                else {
                    intCountRecordsNotSelected++;
                }
            }
            if(intCountRecordsNotSelected == listTotalParentRecords.size()) {
                isVisible = false;
                isChildRecordSectionVisible = false;
                String strMassage = 'Please select atleast one '+ objSettings.Parent_Object__c + ' record from Records Selection section.';
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR , strMassage);
                ApexPages.addMessage(myMsg);
            }
        }
    }
    
     /* Method to add child sObject row with blank values */
    
    public void addBlankRow() {
        if(listWrapperChildRecordsToInsert != NULL && listWrapperChildRecordsToInsert.size() > 0) {
            listWrapperChildRecordsToInsert.add(new ChildWrapper(Schema.getGlobalDescribe().get(objSettings.Child_Object__c).newSObject() , mapChildFieldSets , listWrapperChildRecordsToInsert.size()));
        }
        else {
            listWrapperChildRecordsToInsert = new List<ChildWrapper>();
            listWrapperChildRecordsToInsert.add(new ChildWrapper(Schema.getGlobalDescribe().get(objSettings.Child_Object__c).newSObject() , mapChildFieldSets, 0));
        }
    }
    
    /* Method to remove child sObject row from table */
    
    public void removeChildRecord() {
        if(IndexNumber != NULL) {
            listWrapperChildRecordsToInsert.remove(IndexNumber);
            for(Integer i = 0; i < listWrapperChildRecordsToInsert.size(); i++) {
                listWrapperChildRecordsToInsert[i].rowIndex = i;
            }
        }
    }
    
    /* Method to redirect to home page on cancellation */
    
    public pageReference CancelRecordSelection() {
        PageReference pReference = new pageReference('/home/home.jsp');
        pReference.setRedirect(true);
        return pReference;
    }
    
    /* Method to insert child sObject records */
    
    public void SaveChildRecords() {
        
        isChildRecordSectionVisible = true;
        Integer countSuccess = 0;
        Integer countFailure = 0;
        //Integer intErrorCount = validateDataBeforeSave();
        //system.debug('intErrorCount-----------------------'+intErrorCount);
        system.debug('listWrapperChildRecordsToInsert-----------------------'+listWrapperChildRecordsToInsert);
        //if(listWrapperChildRecordsToInsert != null && listWrapperChildRecordsToInsert.size() > 0 && intErrorCount <= 0) {
            listChildRecords= new List<sObject>();
            for(ChildWrapper objWrapperChild : listWrapperChildRecordsToInsert) {
                if(objWrapperChild.sObjChild != NULL) {
                    listChildRecords.add(objWrapperChild.sObjChild);
                }
            }
            system.debug('listChildRecords-----------------------'+listChildRecords);
            if(listChildRecords != NULL && listChildRecords.size() > 0) {
                //if(intErrorCount <= 0) {
                    isVisible = true;
                    try {
                        insert listChildRecords;
                        system.debug('listChildRecords-----------------------------------'+listChildRecords);
                        //fetchChildRecordFieldsToShow(listChildRecords , objSettings.Child_Object__c);
                        isChildRecordSectionVisible = true;
                        listWrapperChildRecordsToInsert = new List<ChildWrapper>(); 
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO , Label.STR_SUCCESS);
                        ApexPages.addMessage(myMsg);
                        isVisible = true ;
                        isBtnDisabled = true;
                        listTotalParentRecords = new List<ParentWrapper>();
                        objChildSobject = Schema.getGlobalDescribe().get(objSettings.Child_Object__c).newSObject();
                        
                    }
                    catch(Exception e) {
                        system.debug('Exception-----------------------------------'+e);
                        listChildRecords = new List<sObject>();
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR , e.getMessage());
                        ApexPages.addMessage(myMsg);
                    }
                //}
            }
        //}
    }
    
    
    
    
    /* Method to validate child records before insert. */
    
    /*private Integer validateDataBeforeSave() {
        Integer intErrorCount = 0;
        for(ChildWrapper objWrapperChild : listWrapperChildRecordsToInsert) {
            Map<String , Boolean> mapTempRequiredFields = new Map<String , Boolean>();
            for(Schema.FieldSetMember objFieldSetMember : listDefaultFieldMember) {
                if(objFieldSetMember.getDBRequired()) {
                    if(objWrapperChild.sObjChild.get(objFieldSetMember.getFieldPath()) == NULL || objWrapperChild.sObjChild.get(objFieldSetMember.getFieldPath()) == '') {
                        mapTempRequiredFields.put(objFieldSetMember.getFieldPath() , true);
                        intErrorCount++;
                    }
                    else {
                        mapTempRequiredFields.put(objFieldSetMember.getFieldPath() , false);
                    }
                }
            }
            objWrapperChild.mapRequiredFields = mapTempRequiredFields;
            
        }
        return intErrorCount;
    }*/
    
    /* Wrapper class for parent sObject records */
    
    public class ParentWrapper {
        public sObject sObjParent {get; set;}
        public Boolean isSelected {get; set;}
        public String strSobjNameValue {get; set;}
        
        public ParentWrapper(sObject sObjParent , Boolean isSelected , String strSobjNameValue) {
            this.sObjParent = sObjParent;
            this.isSelected = isSelected;
            this.strSobjNameValue = strSobjNameValue;
        }
    }
    
    /* Wrapper class for child sObject records */
    
    public class ChildWrapper {
        public sObject sObjChild {get; set;}
        public Map<String , Boolean> mapRequiredFields {get; set;}
        public Integer rowIndex {get; set;}
        
        public ChildWrapper(sObject sObjChild , Map<String , Boolean> mapRequiredFields) {
            this.sObjChild = sObjChild;
            this.mapRequiredFields = mapRequiredFields;
        }
        
        public ChildWrapper(sObject sObjChild , Map<String , Boolean> mapRequiredFields, Integer rowIndex) {
            this.sObjChild = sObjChild;
            this.mapRequiredFields = mapRequiredFields;
            this.rowIndex = rowIndex;
        }
    }
    
    public class ParentSearchFieldsWrapper {
        public String strFieldAPI {get; set;}
        public Integer Index {get; set;}
        public ParentSearchFieldsWrapper(String strFieldAPI, Integer Index) {
            this.strFieldAPI = strFieldAPI;
            this.Index = Index;
        }
    }
    
    /* Wrapper class for custom Pagination */
    
    public class Paginator {
        public List<ParentWrapper> listPageRecords {get; set;}
        public Boolean isActivePrevious {get; set;}
        public Boolean isActiveNext {get; set;}
        
        public Paginator(List<ParentWrapper> listPageRecords, Boolean isActivePrevious, Boolean isActiveNext) {
            this.listPageRecords = listPageRecords;
            this.isActivePrevious = isActivePrevious;
            this.isActiveNext = isActiveNext;
        }
    }
}