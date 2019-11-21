({
    lazyLoadTabs: function (cmp, event) {
        var tab = event.getSource();
        switch (tab.get('v.id')) {
            case 'releasesum' :
                var attributes = {
                    titleHeader : 'Release Summary View',
                    isEditable : false
                }
                //this.injectComponent('c:RST_ReleaseSumList', tab);
                this.injectComponent('c:RST_TitleDetail', attributes, tab);
                break;
            case 'titledetail' :
                var attributes = {
                    titleHeader : 'Title Detail Summary',
                    isEditable : true
                }
                this.injectComponent('c:RST_TitleDetail', attributes, tab);
                break;
            case 'mc-all' :
                var attributes = {
                    titleHeader : 'Market Capacity All',
                    isEditable : false
                }
                this.injectComponent('c:RST_MarketCapacity', attributes, tab);
                break;
            case 'mc-weekend' :
                var attributes = {
                    titleHeader : 'Market Capacity by Weekend',
                    isEditable : true
                }
                this.injectComponent('c:RST_MarketCapacity', attributes, tab);
                break; 
            case 'upload' :
                var attributes = {}
                this.injectComponent('c:RST_CSVLoader', attributes, tab);
                break;
            case 'add' :
                var attributes = {}
                this.injectComponent('c:RST_NewTitle', attributes, tab);
                break;
        }
    },
    injectComponent: function (name, attributes, target) {
        $A.createComponent(name, attributes, function (contentComponent, status, error) {
            if (status === "SUCCESS") {
                target.set('v.body', contentComponent);
            } else {
                throw new Error(error);
            }
        });
    }
})