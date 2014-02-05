

// Funcions per crear una font de sistema de fitxers. Local file system

function EsquirolSourceFilesystem(id, parentNode) {
    var that = this;

    this.name = '';
    this.doc;
    var fileSystem;
    var dirEntry;

    this.setDirectoryName = function (name) {
        this.name = name;
        console.log('Nom '+name);
    }

    this.getFileSystem = function() {
        window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, function (fs) {
            fileSystem = fs;
            that.getDirectoryEntry();
            }, this.fail);
    }

    this.getDirectoryEntry = function() {
        fileSystem.root.getDirectory(this.name, null, function(de) {
            dirEntry = de;
            that.getFileEntries();
            },this.fail);
    }

    this.getFileEntries = function() {
        var dirReader = dirEntry.createReader();
        dirReader.readEntries(gotFileEntries,that.fail);
    }

    this.showContents = function() {
        this.setDirectoryName('/storage/emulated/legacy/documents/Esquirol');
        this.getFileSystem();
    }

    function gotFileEntries (fileEntries) {
        var node = that.returnBasicNode();
        node.innerHTML = '';
        var table = document.createElement('table');
        table['id'] = 'filelist';
        node.appendChild(table);

        for (var i=0; i<fileEntries.length; i++) {
            item = fileEntries[i];
            if (item['isFile']) {
                var size;
                item.file( function(f) { size = f.size.toString(); });

                var tr = document.createElement('tr');
                table.appendChild(tr);

                var td = document.createElement('td');
                tr.appendChild(td);
                var nomfitxer = document.createTextNode(item['name']);
                td.appendChild(nomfitxer);
                td.href = item['name'];
                td.onclick=function(e) { that.showFile(e.currentTarget['href']); };

                td = document.createElement('td');
                tr.appendChild(td);
                td.appendChild( document.createTextNode(size));

                td = document.createElement('td');
                tr.appendChild(td);
                var modtime = ''; // item.lastModifiedDate.toLocaleDateString();
                td.appendChild( document.createTextNode(modtime));
            }
        }
    }


    this.showFile = function(file) {
        that.signalOpenFile(dirEntry,file);
    }

    this.fail = function(evt) {
        that.signalFail('Fail reading file system ' + evt.target.error.code);
    }

}

// Signals
EsquirolSourceFilesystem.prototype.signalOpenFile = function(dirEntry,filename) { };
EsquirolSourceFilesystem.prototype.signalFail = function(info) { };
