classdef Workbook < jl.office.excel.Workbook
  
  properties
  end
  
  methods
    
    function this = Workbook(varargin)
      if nargin == 0
        this.j = org.apache.poi.hssf.usermodel.HSSFWorkbook();
        return
      end
      if nargin == 1 && isa(varargin{1}, 'org.apache.poi.hssf.usermodel.HSSFWorkbook')
        % Wrap Java object
        this.j = varargin{1};
        return
      end
      error('Invalid input for constructor');
    end
    
    function save(this, file)
      jFile = java.io.File(file);
      this.j.write(jFile);
    end
    
    function out = createCellStyle(this)
      out = jl.office.excel.xls.CellStyle(this.j.createCellStyle);
    end
    
    function out = getDataFormatTable(this)
      out = jl.office.excel.xls.DataFormatTable(this.j.createDataFormat);
    end
    
    function out = createFont(this)
      out = jl.office.excel.xls.Font(this.j.createFont);
    end
    
    function out = createName(this)
      out = jl.office.excel.xls.Name(this.j.createName);
    end
    
  end
  
  methods (Access = protected)
    
    function out = fileFormat(this) %#ok<MANU>
      out = 'xls';
    end
    
    function out = wrapSheetObject(this, jObj)
      out = jl.office.excel.xls.Sheet(this, jObj);
    end
    
    function out = wrapCellStyleObject(this, jObj)
      out = jl.office.excel.xls.CellStyle(this, jObj);
    end
    
  end
  
end