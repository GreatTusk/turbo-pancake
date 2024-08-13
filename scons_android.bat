scons platform=android -j 12
scons platform=android target=template_release -j 12
scons platform=android arch=x86_64 -j 12
scons platform=android arch=x86_64 target=template_release -j 12
echo "Done"