pro print_env

ion_path=getenv('ION_PATH')
print,'ion_path = ',ion_path,'<BR /><BR />'
idl_path=getenv('IDL_PATH')
print,'idl_path = ',idl_path,'<BR /><BR />'
idl_dir=getenv('IDL_DIR')
print,'idl_dir = ',idl_dir,'<BR /><BR />'
ld_lib_path=getenv('LD_LIBRARY_PATH')
print,'ld_library_path = ',ld_lib_path,'<BR /><BR />'
path=getenv('PATH')
print,'path = ',path,'<BR /><BR />'
cedar=getenv('CEDAR_IDL_DIR')
print,'cedar = ',cedar,'<BR /><BR />'
end

