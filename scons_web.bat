scons platform=web -j 12
scons platform=web target=template_release -j 12
scons platform=web threads=no -j 12
scons platform=web threads=no target=template_release -j 12
echo "Done"