public class DatatableHelper {
    public static set<Id> publishEventSet = new set<Id>();
    public static Datatable_Object_Setting__c DatatableSetting {get; set;}
    public static String QueryFilterString {get; set;}
    public static String QuerySortString {get; set;}
    
    public static void getSettings(String DataTableSettingId, String FilterString, String SortString){
        if(DatatableSetting == null){
            QueryFilterString = FilterString;
            QuerySortString = SortString;
            DatatableSetting = [Select Id, Name, Object_API__c, (Select Id, Name, Order__c, Column_API__c, Parent_Object_API__c, FieldName__c, Column_Type__c from Datatable_Column_Settings__r Order By Order__c ASC) from Datatable_Object_Setting__c where Id =:DataTableSettingId];
        }
    }
    
    public static String getData(){
        String query = getQuery();
        List<sObject> dataList = Database.query(query);
        
        String returnData = '';
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartArray();
        for(sObject data : dataList){
            gen.writeStartObject();
            for(Datatable_Column_Setting__c column : DatatableSetting.Datatable_Column_Settings__r){ 
                sObject target = data;
                if(!String.isBlank(column.Parent_Object_API__c)){
                    List<String> parents = column.Parent_Object_API__c.split('\\.');
                    for(String parent : parents){
                        target = target.getSobject(parent);
                    } 
                }
                
                String elementValue = target != null && target.get(column.Column_API__c) != null ? String.valueOf(target.get(column.Column_API__c)) : '';
                gen.writeStringField(column.FieldName__c, check(elementValue));
            }
            gen.writeEndObject();
        }
        gen.writeEndArray();
        returnData = gen.getAsString();
        return returnData;
    }
    
    public static String getColumns(){
        String returnCloumns = '';
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartArray();
        for(Datatable_Column_Setting__c column : DatatableSetting.Datatable_Column_Settings__r){
            gen.writeStartObject();
            gen.writeStringField('label', column.Name);
            gen.writeStringField('fieldName', column.FieldName__c);
            //gen.writeNumberField('initialWidth', 150);
            gen.writeStringField('type', column.Column_Type__c);
            gen.writeEndObject();
        }
        gen.writeEndArray();
        returnCloumns = gen.getAsString();
        
        return returnCloumns;
    }
    
    public static String check(String value){
        if(value == null){
            return '';
        }
        return value;
    }
    
    public static Decimal checkD(Decimal value){
        if(value == null){
            return 0;
        }
        return value;
    }
    
    public static string getQuery(){
        String queryString = '';
        queryString += 'SELECT Id, ';
        
        for(Datatable_Column_Setting__c column : DatatableSetting.Datatable_Column_Settings__r){
            if(String.isBlank(column.Parent_Object_API__c)){
                queryString += column.Column_API__c + ', ';
            }else{
                queryString += column.Parent_Object_API__c + '.' + column.Column_API__c + ', ';
            }
        }
        queryString = queryString.removeEnd(', ');
        
        queryString += ' FROM ' +  DatatableSetting.Object_API__c;
        
        if(!String.isBlank(QueryFilterString)){
            queryString += ' WHERE ' + QueryFilterString;
        }
        
        if(!String.isBlank(QuerySortString)){
            queryString += ' Order By ' + QuerySortString;
        }
        
        return queryString;
    }
}