public with sharing class setFieldValueController {

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
    private static final String STR_ADD = 'Add ';
    private static final String STR_SUBTITLE = ' for Multiple';
    private static final String STR_DT_FORMATE = 'yyyy-MM-dd\'T\'hh:mm:ss\'Z\'';
    private static final String STR_DATE_FORMATE = 'yyyy-MM-dd';
    
    /* statis final string used to display proper error messages */
    
    private static final String STR_NO_DEFAULT_FIELDSET = 'Default Fieldset Not Specified for ';
	private static final String STR_NO_SEARCH_FIELDSET = 'Search Fieldset not Specified for ';
	private static final String STR_FIELDSET_NOT_EXIST = 'Fieldset doesnot exist for ';
	private static final String STR_OBJECT = 'Object ';
	private static final String STR_NOT_EXIST = ' does not exist.';
	private static final String STR_INVALID_TYPE_RELATIONSHIP = 'Invalid field type for relationship ';
	private static final String STR_EXPECTED = '. Expected : ';
	private static final String STR_ACTUAL = ' Actual : ';
	private static final String STR_INVALID_REFERENCE_FIELD = 'Invalid reference field ';
	private static final String STR_RELATIONSHIP = ' for relationship ';
	private static final String STR_LOOKUP_FIELD = 'Lookup relationship field ';
	private static final String STR_NA = ' does not exist on ';
    private static final String STR_NO_RECORD_SELECTED = 'Please select atleast one ';
	private static final String STR_RECORD_SELECTION_SECTION = ' record from Records Selection section.';
	private static final String STR_HOME_PAGE = '/home/home.jsp';
    private static final String STR_INVALID_FIELD = 'Invalid field selected : <b>';
    private static final String STR_IN_SOBJECT = '</b> in <b>';
    private static final String STR_BOLD = '</b>';
            	
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
    
    public Map<String , Boolean> mapChildFieldSets ;
    public Map<Integer , Paginator> mapPaginator;
    
    /* Constructor */
    
    public setFieldValueController() {
        listChildRecords = new List<sObject>();
        hasStandardField = false; 
        isVisible = false;
        IsDataInvalid = true;
        isChildRecordSectionVisible = false;
        listWrapperChildRecordsToInsert = new List<ChildWrapper>();
        listParentRecords = new List<ParentWrapper>();
        listTotalParentRecords = new List<ParentWrapper>();
        
        
    }
    
    /* Method to set up data on page load */
    
    public void viewFieldSetForParentChild() {
        isVisible = true;
        isBtnDisabled = true;
        objSettings = new Bulk_Entry_Settings__c(); 
        try {
        	map<String , String>  mapParam = ApexPages.currentPage().getParameters();
        	system.debug('mapParam--------------------'+mapParam);
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
                strTitle = STR_ADD + objSettings.Child_Object__c + STR_SUBTITLE;
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
                	String strErrorMessage = (objSettings.Parent_List_Field_Set__c == NULL) ? STR_NO_DEFAULT_FIELDSET + objSettings.Parent_Object__c : STR_FIELDSET_NOT_EXIST + objSettings.Parent_Object__c + ' : '+ objSettings.Parent_List_Field_Set__c;
                    displayErrorMessage(strErrorMessage);
                }
                if(objSettings.Search_Criteria_Field_Set__c != NULL && DescribeSObjectResultObj.FieldSets.getMap().containsKey(objSettings.Search_Criteria_Field_Set__c)) {
                    Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(objSettings.Search_Criteria_Field_Set__c);
                    listParentSearchFieldMember = new List<Schema.FieldSetMember>();
                    listParentSearchFieldMember.addAll(fieldSetObj.getFields());
                    showErrorOnParentFieldSelected(listParentSearchFieldMember , objSettings.Search_Criteria_Field_Set__c);
                }
                else {
                	String strErrorMessage = (objSettings.Search_Criteria_Field_Set__c == NULL) ? STR_NO_SEARCH_FIELDSET + objSettings.Parent_Object__c : STR_FIELDSET_NOT_EXIST + objSettings.Parent_Object__c + ' : '+ objSettings.Search_Criteria_Field_Set__c;
                    displayErrorMessage(strErrorMessage);
                }
            }
            else {
                displayErrorMessage(STR_OBJECT +objSettings.Parent_Object__c + STR_NOT_EXIST);
            }
            
            objChildSobject = (mapsObjectType.containsKey(objSettings.Child_Object__c)) ? Schema.getGlobalDescribe().get(objSettings.Child_Object__c).newSObject() : NULL;
            if(objChildSobject != NULL) {
                Schema.DescribeSObjectResult DescribeSObjectResultObjForChild = mapsObjectType.get(objSettings.Child_Object__c).getDescribe();
                strTitle = STR_ADD + DescribeSObjectResultObjForChild.getLabel() + STR_SUBTITLE;
                Map<String , Schema.SObjectField> mapChildsObjectFields = new Map<String , Schema.SObjectField>();
                mapChildsObjectFields = DescribeSObjectResultObjForChild.fields.getMap();
                
                if(objSettings.Lookup_Relationship_field__c != NULL) {
                    if(mapChildsObjectFields.containsKey(objSettings.Lookup_Relationship_field__c.toLowerCase())) {
                        Schema.SObjectField childsObjectField = mapChildsObjectFields.get(objSettings.Lookup_Relationship_field__c.toLowerCase());
                        if(!(childsObjectField.getDescribe().getType() == Schema.Displaytype.Reference)) {
                            displayErrorMessage(STR_INVALID_TYPE_RELATIONSHIP + objSettings.Parent_Object__c + STR_EXPECTED + Schema.Displaytype.Reference + STR_ACTUAL + childsObjectField.getDescribe().getType());
                        }
                        else if(childsObjectField.getDescribe().getReferenceTo().size() > 1) {
                        	Map<String , Schema.Sobjecttype> mapReferenceObjects = new Map<String , Schema.Sobjecttype>();
                        	for(Integer i = 0; i < childsObjectField.getDescribe().getReferenceTo().size(); i++ ) {
                        		mapReferenceObjects.put(String.valueOf(childsObjectField.getDescribe().getReferenceTo().get(i)) , childsObjectField.getDescribe().getReferenceTo().get(i));
                        	}
                        	if(!mapReferenceObjects.containsKey(objSettings.Parent_Object__c)) {
                        		displayErrorMessage(STR_INVALID_REFERENCE_FIELD + objSettings.Lookup_Relationship_field__c + STR_RELATIONSHIP + objSettings.Parent_Object__c);
                        	}
                        }
                        else if(!String.valueOf(childsObjectField.getDescribe().getReferenceTo().get(0)).equalsIgnoreCase(objSettings.Parent_Object__c) ) {
                            displayErrorMessage(STR_INVALID_REFERENCE_FIELD + objSettings.Lookup_Relationship_field__c + STR_RELATIONSHIP + objSettings.Parent_Object__c);
                        }
                    }
                    else {
                        displayErrorMessage(STR_LOOKUP_FIELD + objSettings.Lookup_Relationship_field__c + STR_NA + objSettings.Child_Object__c);
                    }
                }
                else {
                    displayErrorMessage(Label.LOOKUP_FIELD_NOT_SPECIFIED);
                }
                
                if(objSettings.Default_Settings_Field_Set__c != NULL && DescribeSObjectResultObjForChild.FieldSets.getMap().containsKey(objSettings.Default_Settings_Field_Set__c) ) {
                    Schema.FieldSet fieldSetObjForChild = DescribeSObjectResultObjForChild.FieldSets.getMap().get(objSettings.Default_Settings_Field_Set__c);
                    listDefaultFieldMember = new List<Schema.FieldSetMember>();
                    listDefaultFieldMember.addAll(fieldSetObjForChild.getFields());
                    showErrorOnParentFieldSelected(listDefaultFieldMember , objSettings.Default_Settings_Field_Set__c);
                    
                }
                else {
                	String strErrorMessage = (objSettings.Default_Settings_Field_Set__c == NULL) ? STR_NO_DEFAULT_FIELDSET + objSettings.Child_Object__c : STR_FIELDSET_NOT_EXIST + objSettings.Child_Object__c + ' : '+objSettings.Default_Settings_Field_Set__c;
                    displayErrorMessage(strErrorMessage);
                }
                
                if(objSettings.Child_Record_List_Field_Set__c != NULL && DescribeSObjectResultObjForChild.FieldSets.getMap().containsKey(objSettings.Child_Record_List_Field_Set__c) ) {
                    Schema.FieldSet fieldSetObjForChild = DescribeSObjectResultObjForChild.FieldSets.getMap().get(objSettings.Child_Record_List_Field_Set__c);
                    listChildSelectionFieldMember = new List<Schema.FieldSetMember>();
                    listChildSelectionFieldMember.addAll(fieldSetObjForChild.getFields());
                    showErrorOnParentFieldSelected(listChildSelectionFieldMember , objSettings.Child_Record_List_Field_Set__c);
                }
                else {
                	String strErrorMessage = (objSettings.Child_Record_List_Field_Set__c == NULL) ? STR_NO_DEFAULT_FIELDSET + objSettings.Child_Object__c : STR_FIELDSET_NOT_EXIST + objSettings.Child_Object__c + ' : '+objSettings.Child_Record_List_Field_Set__c;
                    displayErrorMessage(strErrorMessage);
                }
            }
            else {
                displayErrorMessage(STR_OBJECT + objSettings.Child_Object__c + STR_NOT_EXIST);
            }
        }
        catch(Exception e) {
            displayErrorMessage(e.getMessage());
        }
    }
    
    public void showErrorOnParentFieldSelected(List<Schema.FieldSetMember> listDefaultFieldMember , String strFieldSet) {
    	for(Schema.FieldSetMember objFieldSetMember : listDefaultFieldMember) {
            if(objFieldSetMember.getFieldPath().contains('.') && objFieldSetMember.getFieldPath().contains(objSettings.Parent_Object__c)) {
            	displayErrorMessage(STR_INVALID_FIELD + objFieldSetMember.getLabel() + STR_IN_SOBJECT + strFieldSet + STR_BOLD);
            }        	
        }
    }
    
    public void displayErrorMessage(String strMessage) {
        IsDataInvalid = false;
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR , strMessage);
        ApexPages.addMessage(myMsg);
    }
    
    
    /* Method to fetch parent records based on search criteria */
    
    public void SearchParentRecords() {
        listWrapperChildRecordsToInsert = new List<ChildWrapper>();
	    listChildRecords = new List<sObject>();
	    isChildRecordSectionVisible = false;
	    isVisible = false;
	        
	    List<sObject> listTempRecords = new List<sObject>();
	    Boolean isFilterCondition = false;
	    
        try {
	        
	        String strQuery = STR_SELECT + SPACE + ID + COMMA + SPACE;
	        if(hasStandardField) {
	            strQuery = strQuery + NAME + COMMA + SPACE; 
	        }
	        if(listParentFieldMember != NULL && listParentFieldMember.size() > 0) {
	            for(Schema.FieldSetMember strParentField : listParentFieldMember) {
	            	if(strParentField.getFieldPath() != ID) {
	            		if(strParentField.getFieldPath().equalsIgnoreCase(NAME)) {
	            			if(!hasStandardField) {
	            				strQuery = strQuery + strParentField.getFieldPath() + COMMA + SPACE;
	            			}
	            		}
	            		else {
	            			strQuery = strQuery + strParentField.getFieldPath() + COMMA + SPACE;
	            		}
	            		
	            	}
	            }
	            for(Schema.FieldSetMember strParentField : listParentSearchFieldMember) {
	            	if(objParentSobject.get(strParentField.getFieldPath()) != null && objParentSobject.get(strParentField.getFieldPath()) != STR_BLANK && !isFilterCondition) {
		                isFilterCondition = true;
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
	                        String strDate = DateTime.newInstance(Date.valueOf(objParentSobject.get(strParentField.getFieldPath())), Time.newInstance(0, 0, 0, 0)).format(STR_DATE_FORMATE);
	                        strQuery  += strDate + SPACE + STR_AND + SPACE;
	                    }
	                    else if(strParentField.getType() == Schema.Displaytype.DateTime) {
	                        String strDateTime = DateTime.valueOf(objParentSobject.get(strParentField.getFieldPath())).format(STR_DT_FORMATE);
	                        strQuery  +=  STR_QUOTE + strDateTime +STR_QUOTE + SPACE + STR_AND + SPACE;
	                    }
	                    else if(strParentField.getType() == Schema.Displaytype.Double || strParentField.getType() == Schema.Displaytype.Integer || strParentField.getType() == Schema.Displaytype.Currency ) {
	                        strQuery  += objParentSobject.get(strParentField.getFieldPath()) + SPACE + STR_AND + SPACE;
	                    }
	                    else if(strParentField.getType() == Schema.Displaytype.Boolean) {
	                    	
	                        strQuery  +=  String.valueOf(objParentSobject.get(strParentField.getFieldPath())) + SPACE + STR_AND + SPACE;
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
	        }
	        else {
	            listParentRecords = new List<ParentWrapper>();
	            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR , Label.SPECIFY_SEARCH_CRITERIA);
	            ApexPages.addMessage(myMsg);
	        }
        }
        catch(Exception e){
        	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR , e.getMessage());
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
                            Paginator objPaginator = (j == TotalPages && lastPageSize == 0)? new Paginator(listTempParent, true, false) :  new Paginator(listTempParent, true, true);
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
                String strMassage = STR_NO_RECORD_SELECTED + objSettings.Parent_Object__c + STR_RECORD_SELECTION_SECTION;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR , strMassage);
                ApexPages.addMessage(myMsg);
            }
        }
    }
    
    /* Method to add child sObject rows with default values */
    
    public void addRowWithDefault() {
    	
        Integer intCountRecordsNotSelected = 0;
        listWrapperChildRecordsToInsert = new List<ChildWrapper>();
        isChildRecordSectionVisible = true;
        try {
	        if(listTotalParentRecords != NULL && listTotalParentRecords.size() > 0) {
	            for(ParentWrapper objParentWrapper : listTotalParentRecords) {
		            if(objParentWrapper.isSelected) {
		                sObject objChildSobjectToInsert = Schema.getGlobalDescribe().get(objSettings.Child_Object__c).newSObject();
		                objChildSobjectToInsert.put(objSettings.Lookup_Relationship_field__c , objParentWrapper.sObjParent.get(ID));
		                for(Schema.FieldSetMember objFieldSetMember : listDefaultFieldMember) {
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
	                String strMassage = STR_NO_RECORD_SELECTED + objSettings.Parent_Object__c + STR_RECORD_SELECTION_SECTION;
	                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR , strMassage);
	                ApexPages.addMessage(myMsg);
	            }
	        }
        }
        catch(Exception e) {
        	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR , e.getMessage());
	        ApexPages.addMessage(myMsg);
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
        PageReference pReference = new pageReference(STR_HOME_PAGE);
        pReference.setRedirect(true);
        return pReference;
    }
    
    /* Method to insert child sObject records */
    
    public void SaveChildRecords() {
    	
        isChildRecordSectionVisible = true;
        Integer countSuccess = 0;
        Integer countFailure = 0;
        
        
        listChildRecords= new List<sObject>();
        for(ChildWrapper objWrapperChild : listWrapperChildRecordsToInsert) {
            if(objWrapperChild.sObjChild != NULL) {
                listChildRecords.add(objWrapperChild.sObjChild);
            }
        }
            
        if(listChildRecords != NULL && listChildRecords.size() > 0) {
            isVisible = true;
            try {
            	
                insert listChildRecords;
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
                listChildRecords = new List<sObject>();
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR , e.getMessage());
                ApexPages.addMessage(myMsg);
            }
        }
    }
    
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