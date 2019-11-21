global with sharing class RST_MagicYearIterable implements Iterable<String> {
    //private String query;

    global RST_MagicYearIterable(){
        //query = soql;
    }

    global Iterator<String> Iterator(){
        return new RST_MagicYearIterator();
    }
}