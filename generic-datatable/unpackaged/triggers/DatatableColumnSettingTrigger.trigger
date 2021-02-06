trigger DatatableColumnSettingTrigger on Datatable_Column_Setting__c (after insert, after update, before delete) {
    List<Datatable_Column_Update__e> columnEvents = new List<Datatable_Column_Update__e>();
    List<Datatable_Column_Setting__c> dataset = Trigger.isDelete ? trigger.old : trigger.new;
    for(Datatable_Column_Setting__c setting : dataset){
        if(!DatatableHelper.publishEventSet.contains(setting.Datatable_Object_Setting__c)){
            DatatableHelper.publishEventSet.add(setting.Datatable_Object_Setting__c);
            columnEvents.add(new Datatable_Column_Update__e(Datatable_Object_Setting_Id__c=String.valueOf(setting.Datatable_Object_Setting__c).substring(0, 15)));
        }
    }
    if(columnEvents != null && columnEvents.size() > 0){
       EventBus.publish(columnEvents); 
    }
}