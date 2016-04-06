public with sharing class DatePickerController {
    public Date currentDate{get; set;}

    public DatePickerController () {
    	//String strDate = DateTime.newInstance(Date.valueOf(objParentSobject.get(strParentField.getFieldPath())), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
        //currentDate = DateTime.newInstance(Date.Today() , Time.newInstance(0, 0, 0, 0)).format('MM/dd/yyyy');
        currentDate = Date.parse(DateTime.newInstance(Date.Today() , Time.newInstance(0, 0, 0, 0)).format('MM/dd/yyyy'));
    }
}