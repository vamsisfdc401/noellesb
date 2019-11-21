global with sharing class RST_TitleYearIterable implements Iterable<AggregateResult> {
    private String query;

    global RST_TitleYearIterable(String soql){
        query = soql;
    }

    global Iterator<AggregateResult> Iterator(){
        return new RST_TitleYearIterator(query);
    }
}