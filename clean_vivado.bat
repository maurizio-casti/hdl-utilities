echo off                                          
md Vivado_tmp                                     
xcopy Vivado\*.xpr Vivado_tmp\*.xpr               
rd /s /q Vivado                                   
md Vivado                                         
xcopy Vivado_tmp\*.xpr Vivado\*.xpr               
rd /s /q Vivado_tmp                               
echo "Finished: Vivado folder cleaned"            
