public class DatatableWrap {
    @AuraEnabled public String columns {get;set;}
    @AuraEnabled public String data {get;set;}
    
    public DatatableWrap(String DataTableSettingId, String FilterString, String SortString){
        DatatableHelper.getSettings(DataTableSettingId, FilterString, SortString);
        columns = DatatableHelper.getColumns();
        data = DatatableHelper.getData();
    } 
}