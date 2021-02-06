public with sharing class DatatableController {
    @AuraEnabled (cacheable=false)
    public static DatatableWrap getTableDetails(String DataTableSettingId, String FilterString, String SortString){
        System.debug('DataTableSettingId' + DataTableSettingId);
        DatatableWrap tableWrap = new DatatableWrap(DataTableSettingId, FilterString, SortString);
        return tableWrap;
    }
}