classdef Workbook < jl.office.excel.Workbook
  
  properties
  end
  
  methods
    
    function this = Workbook(varargin)
      if nargin == 0
        this.j = org.apache.poi.xssf.usermodel.XSSFWorkbook();
        return
      end
      if nargin == 1 && isa(varargin{1}, 'org.apache.poi.xssf.usermodel.XSSFWorkbook')
        % Wrap Java object
        this.j = varargin{1};
        return
      end
      error('Invalid input for constructor');
    end
    
    function save(this, file)
      %SAVE Write this workbook out to a file in .xlsx format
      %
      % save(obj, file)
      %
      % file (char, str) is the path to the file to write out to. Overwrites any
      % existing file.
      %
      % Throws an error if the write operation fails for any reason.
      
      pid = feature('getpid');
      tmpFile1 = sprintf('%s.%d.orig.tmp', file, pid);
      tmpFile2 = sprintf('%s.%d.fixed.tmp', file, pid);
      
      jOutStream = java.io.FileOutputStream(tmpFile1);
      this.j.write(jOutStream);
      jOutStream.close();
      
      % When running under matlab, POI produces bad files with the "xmlns="
      % attribute missing on some elements. (I have no idea why.) So we have to
      % fix them up.
      % See: https://stackoverflow.com/questions/59811366/apache-poi-3-16-creates-invalid-files-when-run-inside-matlab?noredirect=1#comment105804128_59811366
      
      zIn = jl.util.ZipFile(tmpFile1);
      zOut = jl.util.ZipWriter.forFile(tmpFile2);
      zEntries = zIn.getEntries;
      for iEntry = 1:numel(zEntries)
        zEntry = zEntries(iEntry);
        bytes = zIn.getContents(zEntry);
        needToEdit = {'[Content_Types].xml', '_rels/.rels', 'docProps/core.xml' ...
          'xl/_rels/workbook.xml.rels'};
        if ismember(zEntry.name, needToEdit)
          str = native2unicode(bytes, 'UTF-8')';
          str = strrep(str, '<Types>', '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">');
          str = strrep(str, '<Relationships>', '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">');
          bytes = unicode2native(str, 'UTF-8');
        end
        zEntryOut = jl.util.ZipEntry(zEntry.name);
        if ~ismissing(zEntry.comment)
          zEntryOut.comment = zEntry.comment;
        end
        extra = zEntry.getExtra;
        if ~isempty(extra)
          zEntryOut.setExtra(extra);
        end
        if ~isnat(zEntry.creationTime)
          zEntryOut.creationTime = zEntry.creationTime;
        end
        if ~isnat(zEntry.lastAccessTime)
          zEntryOut.lastAccessTime = zEntry.lastAccessTime;
        end
        zOut.writeEntry(zEntryOut, bytes);
      end
      zIn.close;
      zOut.close;
      delete(tmpFile1);
      movefile(tmpFile2, file);
    end

    function out = createCellStyle(this)
      out = jl.office.excel.xlsx.CellStyle(this.j.createCellStyle);
    end

    function out = createFont(this)
      out = jl.office.excel.xlsx.Font(this.j.createFont);
    end
    
    function out = createName(this)
      out = jl.office.excel.xlsx.Name(this.j.createName);
    end
    
  end
  
  methods (Access = protected)
    
    function out = fileFormat(this) %#ok<MANU>
      out = 'xlsx';
    end
        
  end
  
end