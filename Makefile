# Copyright 2020 AT&T Intellectual Property.  All other rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

demo_dag_gen:
	./examples/run.sh armadaworkflow dag_gen armadaworkflow-dag

demo_groups_gen:
	./examples/run.sh armadaworkflow groups_gen armadaworkflow-groups

demo_chart_gen: clean
	mkdir examples/functions/resolved/
	cp -r examples/functions/gen/* examples/functions/resolved/
	./examples/run.sh armadachart types/example airship-software-deploy

demo_static_embedded: clean
	mkdir examples/functions/resolved/
	cp -r examples/functions/static/embedded/* examples/functions/resolved/
	./examples/run.sh "" types/example airship-software-deploy

demo_static_secrets: clean
	mkdir examples/functions/resolved/
	cp -r examples/functions/static/secrets/* examples/functions/resolved
	./examples/run.sh "" types/example airship-software-deploy

demo_static_custom_resources: clean
	mkdir examples/functions/resolved/
	cp -r examples/functions/static/custom_resources/* examples/functions/resolved/
	./examples/run.sh "" types/example airship-software-deploy

clean:
	rm -rf examples/functions/resolved/
