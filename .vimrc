source ~/.bundles.vim


set wildignore+=*.o,*.obj,.git*,*.rbc,*.class,.svn,vendor/gems/*,*/tmp/*,*.so,
  \*.swp,*.zip,*/images/*,*/cache/*,dist/,platforms/,node_modules/*,*Godeps/_workspace*
call unite#custom#source('file_rec/async', 'ignore_globs', split(&wildignore, ','))

