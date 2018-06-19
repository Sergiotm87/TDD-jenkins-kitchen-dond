# Despliegue continuo de infraestructuras

## Introducción

La idea principal de este proyecto es crear una herramienta para facilitar el desarrollo de infraestructuras a partir de unas especificaciones sobre las que realizar un conjunto de pruebas usando proyectos de software libre.

## Contenido

- [Descripción](#descripción)
- [Conceptos y herramientas](#conceptos-y-herramientas)
  * [Infrastructure as Code](#infrastructure-as-code)
  * [Test Driven Development](#test-driven-development)
- [Uso](#uso)
- [Desarrollo y pruebas](#desarrollo-y-pruebas)
- [Conclusiones](#conclusiones)
- [Trabajo futuro](#trabajo-futuro)
- [Referencias](#referencias)

### Descripción

Este repositorio es una prueba de concepto sobre la automatización en el despligue de infraestructuras en las etapas iniciales de un proyecto mediante el uso del desarrollo basado en pruebas (TDD) y contenedores docker como herramienta de desarrollo.

Las herramientas usadas son:

* [test-kitchen](#test-kitchen)
* [jenkins](#jenkins)
* [docker](#docker)
* [ansible](#ansible)
* [inspec](#inspec)
* [cookiecutter](#cookiecutter)

El proceso completo lo forman las pruebas en el entorno local y el despliegue de la infraestructura una vez pasadas las pruebas.

### Conceptos y herramientas

#### Infrastructure as Code

La infraestructura como código es un concepto que se puede resumir en agilizar procesos repetitivos de manera eficiente mediante código fuente, destacando como algunas de sus caractarísticas:

* Automatización de la configuración con scripts u otras herramientas que trabajen con ficheros de texto legibles por una máquina preferiblemente de manera declarariva frente a la procedural (definiendo qué se desea obtener en lugar de los pasos necesarios para lograrlo). Algunos ejemplos de herramientas que permiten esta tarea son ansible,terraform,chef, saltstack, scripts en bash u otros lenguajes de programación.

* Uso de control de versiones como git que permita controlar de manera organizada las diferentes configuraciones así como un desarrollo ágil de estas.

> “If you automate a mess, you get an automated mess.” (Rod Michael)

#### Test Driven Development

El desarrollo basado en pruebas es una práctica muy usada en el desarrollo de software que intenta reducir el tiempo y la complejidad de los ciclos de desarrollo mediante la iteración del proceso de desarrollo de código y la ejecución de tests.

A partir de un conjunto de requisitios se definen las funcionalidades básicas necesarias y se desarrollan los tests para validar cada funcionalidad. A continuación se desarrolla el código de las funcionalidades y según se vayan superando los test se van desarrollando las de orden superior (que deben pasar todos los test anteriores) hasta cumplir con todos los requisitos de un proyecto. Esto facilita la división de tareas y su desarrollo. De manera resumida los test se pueden diferenciar según su cometido:

* Test unitarios: comprueban que una funcionalidad básica cumple su tarea (ej. todas las dependencias están disponibles ó un servicio está levantado correctamente).
* Test de integración: se realizan sobre un conjunto de funcionalidades a la vez (ej. la aplicación web puede realizar consultas sobre la base de datos ó el balanceo de carga funciona correctamente). Requieren mayor complejidad que los test unitarios y que éstos hayan sido pasados correctamente.
* Test funcionales: realiza los test sobre todo el conjunto de la aplicación. Puede requerir usar herramientas diferentes a los test anteriores como [selenium](https://www.seleniumhq.org/) y son ejecutadas desde la experiencia del usuario o cliente final de la aplicación. Estas pruebas también son definidas como desarrollo basado en el comportamiento (Behaviour driven development).

En el caso de las infraestructuras debemos tener en cuenta que las tecnologías de aprovisionamiento modernas tienen características que pueden hacer innecesario el uso de test unitarios para comprobar una tarea como son el uso declarativo de terraform o el obtener el resultado de un rol de ansible durante su ejecución, aun así pueden ser de gran utilidad durante la etapa de desarrollo ó para comprobar la seguridad de la infraestructura (ej. realizando escaneos de puertos,comprobando procesos o permisos que hayan podido cambiar debido a los cambios ejecutados). Los test funcionales pueden realizar pruebas más complejas que excedan del alcance de las herramientas de aprovisionamiento y pueden ser las más interesantes en un projecto de este tipo.

>“Bad programmers have all the answers. Good testers have all the questions.” (Gil Zilberfeld)

#### Test kitchen

Software desarrollado por el equipo de chef en lenguaje ruby que permite testear infraestructuras en diferentes tipos de plataformas. Mediante un fichero de configuración en formato yaml levanta una máquina virtual y ejecutar sobre ella los test, al terminar devuelve el resultado y destruye la máquina virtual lo que lo convierte en una herramienta perfecta para entornos de integración continua de aprovisionamiento de infraestructuras.

Existen multitud de plugins tanto oficiales como creados por la comunidad para usar diferentes tecnologías:

* Aprovisionamiento - Chef,Ansible,Terraform,Salt stack

* Arquitecturas - Vagrant,Docker,Qemu y proveedores cloud como AWS EC2, Google GCE u Openstack

* Test - Inspect,Serverspec,Bats,Minitest

#### Jenkins

Software libre por excelencia para procesos de automatización en el desarrollo de software, integración y desarrollo continuo. Su funcionamiento está basado en tareas que realizan funciones como validar código a través de pruebas específicas, construir los ejecutables a partir del código fuente o su documentación, realizar test de carga y aceptar o denegar un pull-request sobre una rama específica a partir de alguna de las funcionalidades anteriores. Estas tareas tienen como punto central un software de control de versiones como git y la multitud de plugins generados por la comunidad.

Esta herramienta es la pieza central que ejecuta los tests y que permite extender las funcionalidades
o ser integrado en otros escenarios y proyectos.

#### Docker

Los contenedores docker son ampliamente usados en entornos de desarrollo y procesos de integración continua:

* El uso de sistemas de ficheros por capas permite construcciones más rápidas gracias al uso de caché sobre todas las capas ya existentes.

* Su construcción a partir de código fuente facilita la portabilidad y la posibilidad de usar control de versiones.

* El aislamiento del equipo anfitrión permite controlar que se usan las dependencias precisas de la aplicación que corre el contenedor.

En esta herramienta se usa la capacidad de compartir el socket de docker del anfitrión para lanzar los test sobre nuevos contenedores docker, característica conocida como docker-on-docker. El caso extremo de esta funcionalidad es docker-in-docker corriendo contenedores anidados lo que durante mucho tiempo no se ha  recomendado por la posibilidad de corrupción de los sistemas de ficheros si no se controla qué [storage driver](https://docs.docker.com/storage/storagedriver/select-storage-driver/) o qué [imágenes](https://hub.docker.com/_/docker/) podemos utilizar ([referencia](http://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/)).

### Uso

Primero hay que levantar el escenario compuesto por dos repositorios. Los requisitos previos son tener docker, docker-compose, python y python-pip instalados y el repositorio TDD. Aunque no es necesario si se siguen los pasos se recomienda un conocimiento básico del funcionamiento de docker y docker-compose.

* TDD-jenkins-kitchen-dond: contiene el Dockerfile con el código de la aplicación, la configuración de jenkins, un fichero Makefile para construir la imagen y el docker-compose para desplegarlo. La configuración e historial de jenkins son persistentes.

* Cookiecutter-kitchen-ansible: es una plantilla que se rellena al ejecutar el comando 'cookiecutter https://github.com/k4mmin/cookiecutter-kitchen-ansible' donde se especifican los parámetros necesarios para realizar las pruebas como el repositorio con el playbobok de ansible, si se realiza una prueba local o se genera un repositorio nuevo, autor y fecha (para realizar un repositorio nuevo debe generarse un token git previamente). La plantilla tiene unos valores por defecto con los que realizar las pruebas de una imagen docker con wordpress,nginx, mysql y php-fpm a través de ansible e inspec.

Pasos a dar para realizar una prueba

```
git clone https://github.com/k4mmin/TDD-jenkins-kitchen-dond.git
cd TDD-jenkins-kitchen-dond
```

Clonar el repositorio TDD, dentro de este instalar los requisitos en un entorno virtual python y levantar el contenedor con la aplicación con los siguientes comandos:

```
virtualenv venv
source venv/bin/activate
```

Activa el entorno virtual de python para instalar los requisitos de manera local.

```
pip install -r requirements.txt
```

Instala los requisitos python. Gracias al entorno virtual podemos instalar las dependencias como usuario no privilegiado y sin que interfiera con otros paquetes instalados en el equipo.

```
make build
```

Crea la imagen docker con los parámetros establecidos en el fichero Makefile. El nombre de la imagen debe coincidir con la indicada en el fichero docker-compose.

```
cookiecutter https://github.com/k4mmin/cookiecutter-kitchen-ansible -o volumes/projects/
```

Obtiene la plantilla de ese repositorio y rellena un formulario por consola que deja preparado el escenario sobre el que correr las pruebas.

```
docker-compose up -d
```

Levanta un contenedor a partir de la imagen anterior con una configuración específica (variables de entorno, puertos mapeados del equipo anfitrión, red a utilizar y volúmenes persistentes a utilizar ). Una vez desplegado el contenedor podemos comprobar su estado con el comando 'docker ps' para comprobar si está disponible.

El último paso es entrar en jenkins y correr el escenario.

## Desarrollo y pruebas

El primer paso de este proyecto ha sido estudiar las herramientas de software libre para la ejecución de tests sobre infraestructuras. La primera prueba completa realizada ha sido con vagrant y el plugin de serversec ([link](https://github.com/vvchik/vagrant-serverspec)), un escenario muy sencillo de reproducir para conocer alguna herramienta de tests usando un rol de ansible-galaxy.

Vagrantfile
```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "geerlingguy/ubuntu1604"
  config.ssh.insert_key = false

  config.vm.provider :virtualbox do |v|
    v.name = "lamp"
    v.memory = 512
    v.cpus = 2
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--ioapic", "on"]
  end

  config.vm.hostname = "lamp"
  config.vm.network :private_network, ip: "192.168.33.33"

  # Set the name of the VM. See: http://stackoverflow.com/a/17864388/100134
  config.vm.define :lamp do |lamp|
  end

  # Ansible provisioner.
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "provisioning/playbook.yml"
    ansible.inventory_path = "provisioning/inventory"
    ansible.sudo = true
  end

  config.vm.provision :serverspec do |spec|
    spec.pattern = '*_spec.rb'
    Specinfra.configuration.sudo_password = 'vagrant'
  end
end
```

provisioning/playbook.yml
```yaml
---
- hosts: lamp
  gather_facts: yes

  vars_files:
    - vars/main.yml

  roles:
    - geerlingguy.apache
```

requirements.yml
```yaml
---
- src: geerlingguy.repo-remi
- src: geerlingguy.apache
```

provisioning/vars/main.yml
```yaml
---
apache_enablerepo: remi
apache_vhosts:
  - {servername: "lamp", documentroot: "/var/www/html"}
```

test_spec.rb
```ruby
require_relative 'spec_helper'

describe package('apache2') do
  it { should be_installed }
end

describe service('apache2') do
  it { should be_enabled }
  it { should be_running }
end

describe port(80) do
  it { should be_listening }
end
```

spec_helper.rb
```ruby
#require 'serverspec'
#require 'net/ssh'

#set :backend, :ssh

# Disable sudo
# set :disable_sudo, true

# Set environment variables
# set :env, :LANG => 'C', :LC_MESSAGES => 'C'

# Set PATH
# set :path, '/sbin:/usr/local/sbin:$PATH'
```

Uso

```shell
ansible-galaxy install geerlingguy.repo-remi geerlingguy.apache
vagrant plugin install vagrant-serverspec
vagrant up --provision
```

A partir del funcionamiento de este escenario se busca una herramienta que funcione de la misma manera pero sin requerir distintas instalaciones, dependencias o configuraciones.

Se decide usar kitchen para ocuparse de levantar y destruir las máquinas virtuales y que no sea necesario crear tantos ficheros de configuración. Junto con ansible y vagrant se realizan las pruebas y paso a estudiar cómo realizar tareas más complejas por ejemplo integrarlo con software de control de versiones y crear un proceso de desarrollo continuo.

Se elije jenkins para controlar todo el proceso gracias a su gran número de plugins
disponibles y la posibilidad de crear diferentes flujos de trabajo mediante la creación de tareas.

Para las pruebas comienzo utilizando serverspec e inspec.

Realizo una instalación corriente de jenkins y kitchen como se describe en sus webs ([jenkins](https://jenkins.io/doc/book/installing/#debian-ubuntu),[kitchen](https://kitchen.ci/docs/getting-started/installing)) y realizo algunas pruebas con playbooks sencillos y diferentes tipos de drivers para kitchen hasta conocer cómo se debe crear el fichero de configuración '.kitchen.myl' (depende en gran medida de qué drivers se utilizen, [ejemplo](https://github.com/k4mmin/cookiecutter-kitchen-ansible/blob/master/%7B%7Bcookiecutter.role_name%7D%7D/.kitchen.yml)). Al intentar usar roles creados por la comunidad o escenarios complejos que involucren crear varias máquinas virtuales voy dándome cuenta que el tiempo que tardo en generar un directorio con los ficheros correctos de kitchen y ansible es demasiado largo y decido automatizar estas tareas.

Este es un punto de inflexión puesto que ya he probado una herramienta relativamente sencilla de utilizar para mostrar un caso de uso y poder estudiar la utilidad de los test sobre la creación de infraestructuras además de poder aplicarse a procesos de integración y desarrollo continuo. Finalmente tomo la decisión de seguir con el desarrollo a través de la automatización completa de la instalación y el uso de la herramienta para que pueda ser usado por terceros.

Para poder usarse con facilidad se hace necesario algún procedimiento que cree los ficheros de configuración necesarios, el aprovisionamiento y los test. Las opciones que tomo válidas son realizar un script bash o hacer uso de plantillas tipo jinja2 en python. La opción de las plantillas resulta ser la más eficiente cuando comienzo a trabajar con cookiecutter con el desarrollo del repositorio cookiecutter-kitchen-ansible a partir de un repositorio cuya función es agilizar la creación de roles de ansible-galaxy. ([link](https://github.com/ferrarimarco/cookiecutter-ansible-role)).

La instalación más sencilla que encuentro para un usuario es levantar un contenedor docker que contenga todo el software y las dependencias. Realizo un dockerfile que contenga jenkins, ruby, ansible y git comenzando desde una imagen base debian stretch para finalmente usar la imagen oficial de jenkins ([link](https://github.com/k4mmin/TDD-jenkins-kitchen-dond/blob/master/Dockerfile)).

Como parte del estudio del software kitchen se comprobó que usando el driver de docker se reducía el tiempo de creación del entorno para los test con la ventaja de que se genera una imagen docker lista para ser usada una vez se superan las pruebas y lo más importante, se obtiene la capacidad de realizar test funcionales sobre la aplicación generada. Éstas imágenes no deberian usarse en producción porque incluyen dependencias innecesarias
pero pueden usarse para seguir con el desarrollo de una infraestructura compuesta por diferentes componentes/servicios. Para poder usar la api de docker dentro de un contenedor es necesario montar el socket del equipo anfitrión dentro del contenedor como se indica en el fichero docker-compose ([link](https://github.com/k4mmin/TDD-jenkins-kitchen-dond/blob/master/docker-compose.yml)).

Se genera una nueva imagen con jenkins, kitchen, docker y sus dependencias. Se encuentran una serie de problemas que se describen a continuación. Después de solucionarse de manera interactiva dentro del contenedor se realiza un fork del plugin kitchen-docker en el que realizar los cambios necesarios para generar una gema ruby personalizada ([link](https://github.com/k4mmin/kitchen-docker/blob/master/lib/kitchen/driver/docker.rb)). Estos cambios tomaron la mayor parte del tiempo de desarrollo del proyecto (tanto por localizar la causa de los problemas como su solución usando el lenguaje de programación ruby):

#### Uso de ipv6 en el contenedor

Es necesario desactivar ipv6 para usar kitchen-docker dentro del contenedor. Al iniciar el proceso se crea a través de la api de docker el nuevo contenedor pero no consigue conectarse a él.

Se intenta priorizar ipv4 en el contenedor modificando el fichero gai.conf sin conseguir el resultado deseado y se soluciona de manera provisional modificando el fichero /etc/hosts del contenedor kitchen([link](https://unix.stackexchange.com/a/45609)).

#### Problema con la conexion ssh al contenedor generado

No se parsea bien el host:puerto del contenedor al que realizar la conexion ssh

```shell
Successfully built 732d471f8b28
b3f733a1eb1ebc9ec702d3f299e4b8d7e6e2c3d18a3bbe942f3b6f3bf8cfb84b
0.0.0.0:32773
Waiting for SSH service on localhost:32773, retrying in 3 seconds
Waiting for SSH service on localhost:32773, retrying in 3 seconds
```

Se encuentra en las issues del repositorio una solución parcial que realiza una modificación de la gema ruby de kitchen-docker. Descargo el repositorio de la gema kitchen-docker con la feature que permite conectar al nuevo contenedor y se generar la gema ruby.

```shell
git clone https://github.com/test-kitchen/kitchen-docker.git
git fetch origin pull/283/head:pull_283
git checkout pull_283
gem build kitchen-docker
```

Se genera una nueva imagen con la gema local pero sigue sin conectar por SSH. Parto de estos cambios que resuelven algunas dudas sobre el funcionamiento de kitchen-docker y ruby.

Uno de los problemas es la red en la que se levanta el contenedor impidiendo la conectividad (al usar docker-compose dejamos de usar la red por defecto). Se modifica la funcion 'def_build_run_command(image_id)' para usar la red generada por docker-compose.

```ruby
cmd= "run -d -p 22 --net=dockerkitchen_default"
```

Se añade a la función container_ssh_port(state) usar el puerto 22 si se utiliza docker-on-docker (requiere añadir el parámetro 'use_internal_docker_network: true' al fichero .kitchen.yml)

```ruby
if config[:use_internal_docker_network]
  return 22
end
```

Se creaa una nueva función 'container_ip(state)'' para obtener la ip del contenedor generado al que conectar

```shell
def container_ip(state)
  begin
    cmd = "inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'"
    cmd << " #{state[:container_id]}"
    docker_command(cmd)
  rescue
    raise ActionFailed,
    'Error getting internal IP of Docker container'
  end
end
```

Con todos estos cambios los test funcionan una vez creada y desplegada la imagen.

## Conclusiones

La primera conclusión a la que puedo llegar después del trabajo realizado es que si bien ha sido un proyecto interesante el tiempo dedicado a la programación a superado con creces lo que tenía programado.

Por un lado no he llegado a implementar el último paso de mi idea inicial la cual era desplegar en una infraestructura un cambio con herramientas de aprovisionamiento previa validación de los cambios mediante el uso de test específicos en un entorno local. Esta falta de funcionalidad no me preocupa porque es un paso que será implementado próximamente. Lo que me preocupa es no haber llegado a hacer una comparativa decente con otras herramientas y que haya sido un trabajo mucho mas práctico que teórico.

Otras herramientas sobre las que he realizado pequeñas pruebas tienen aspectos interesantes para un proyecto de este tipo, por nombrar las que me han parecido más revelantes:

**tests de infraestructuras:** [Molecule](https://molecule.readthedocs.io),[Cucumber](https://cucumber.io/),[Testinfra](https://testinfra.readthedocs.io)

**creación de imágenes:** [Packer](https://www.packer.io/)

**integración continua:** [Travis](https://travis-ci.org/),[Circleci](https://circleci.com/)

Finalmente no he podido realizar un desarrollo de infraestructura usando la herramienta terminada con un ciclo definido de desarrollo basado en diferentes tipos de tests y funcionalidades. Seguiré desarrollando estos aspectos en el futuro con una hoja de ruta bastante clara.

## Trabajo futuro

Durante el desarrollo del proyecto he encontrado cambios que serán implementados próximamente y otras funcionalidades que serán estudiadas para aprender sobre las herramientas asociadas.

#### A realizar próximamente
Cambios conocidos que deben ser arreglados o funcionalidades no terminadas:

- Tagear las imágenes docker construidas cuando se cumplen los test o destruirlas si no se pasan.

- Recrear la imagen docker con los permisos necesarios (por ejemplo el directorio con las gemas ruby) para que el usuario jenkins no necesite ejecutar los test con sudo. (nota: otra opción de ser necesario correr en 'privileged' es [remapear](https://docs.docker.com/engine/security/userns-remap/) el usuario root a otro usuario en el host )

- Realizar builds automáticas de la imagen en [docker-hub](https://hub.docker.com/) (nota: añadir webhook para usar travis [ejemplo](https://medium.com/mobileforgood/coding-tips-patterns-for-continuous-integration-with-docker-on-travis-ci-9cedb8348a62))

- Estudiar el problema con el uso de ipv6 dentro del contenedor a la hora de lanzar kitchen (en este momento se arregla con el script del entrypoint y se utiliza ipv4) para que pueda usarse ipv6 (nota: repasar el fichero /etc/gai.conf).

- Crear nuevas tareas de jenkins con ejemplos de lo que permite hacer este proyecto (ej. uso de jenkinsfile para el caso de kitchen o controlar pull-requests según el resultado de las pruebas)

#### Medio plazo
Funcionalidades que pueden ser mejoradas o que se han estudiado previamente y se pueden realizar sin añadir complejidad al proyecto en general:

- Mejorar el código de la gema kitchen-docker y abrir un pull request en el repositorio como aporte al resto de la comunidad (nota: eliminar el uso de una red específica en la linea 340 de docker.rb).

- Realizar los pasos necesarios para que pueda lanzarse el playbook en un equipo remoto una vez pasados los test por ejemplo en una instancia de Amzon EC2 (tras el cambio de vagrant a docker ha pasado de ser una prioridad a una funcionalidad extra, ahora se obtiene una imagen que puede ser usada directamente)(nota: probar la gema [kitchen-ec2](https://github.com/test-kitchen/kitchen-ec2)).

- Realizar test funcionales sobre la imagen generada (ej selenium sobre aplicación web) y estudiar como realizarlos desde jenkins. (nota: probar [Pipeline Plugin](https://wiki.jenkins.io/display/JENKINS/Pipeline+Plugin)).

- Traducir la documentación del repositorio al ingles para que sea más accesible a la comunidad.

- Añadir una mayor personalización a la plantilla del repositorio cookiecutter para permitir usar otras herramientas de tests de infraestructuras. Mejorar los script post-gen y pre-gen añadiendo 'build trigger' de jenkins, evitar preguntas en el formulario si existen sus correspondientes variables definidas, refactorizar el código de librerias git. Ejemplo de estilo a seguir para la creación del formulario:

```python
#!/usr/bin/env python
from __future__ import unicode_literals, absolute_import, print_function

import os
import shutil
from collections import OrderedDict
from cookiecutter.prompt import read_user_yes_no

try:
    input = raw_input
except NameError:
    pass

question = OrderedDict()
question['remote']= {
    'question': '\nShould it create remote repo? ',
    'description': '  Create a new github repo with all the files '
}

def configure_role():
    print('\n\PROJECT CONFIGURATION:\n===================')
    if read_user_yes_no(question['remote'], default_value=u'yes'):
        print('creando nuevo repo....')
    else:
        print('nop')

if __name__ == '__main__':
    configure_role()
```

- Crear imagen de prueba con [tini](https://github.com/krallin/tini/issues/8)(proceso init),[supervisord](http://supervisord.org/introduction.html)(control de procesos) y entrypoint.sh para poder reiniciar jenkins.

- Comprobar la ventaja de usar una construcción 'multi-stage' para usar una imagen base más ligera que contenga por un lado jenkins y a continuación el actual dockerfile ([ejemplo](https://docs.docker.com/develop/develop-images/multistage-build/)).

- Crear una imagen con travis para la ejecución de escenarios sencillos de manera local y dejar jenkins para aquellos escenarios que requieran mayor número de pasos o integrarse con otras herramientas (en relación con el punto anterior).

#### En el futuro
Nuevas funcionalidades que añaden mayor complejidad al proyecto o que no se han estudiado y requieren un tiempo de desarrollo desconocido:

- Añadir la opción de crear una imagen con Packer en lugar de la imagen docker al finalizar los tests.

- Implementar el uso de roles de ansible-galaxy (indicar al rellenar la plantilla un conjunto de roles en lugar de un repositorio previamente preparado como en el caso de wordpress).

- Crear o adaptar algún mecanismo para crear los test de manera rápida (por ejemplo una web flask/django para construir los test por bloques).

## Referencias

test-kitchen    https://kitchen.ci/ https://docs.chef.io/kitchen.html https://github.com/test-kitchen/test-kitchen

jenkins         https://jenkins.io/ https://github.com/jenkinsci/jenkins

docker          https://www.docker.com/

ansible         https://www.ansible.com/

inspec          https://www.inspec.io/ https://github.com/inspec/inspec

cookiecutter    https://github.com/audreyr/cookiecutter


- gema kitchen-ansible
https://github.com/neillturner/kitchen-ansible

- ejemplos de kitchen-docker con ansible
https://github.com/mheap/kitchen-ansible-docker-example
https://werner-dijkerman.nl/2015/08/20/using-test-kitchen-with-docker-and-serverspec-to-test-ansible-roles/

- proyecto similar
https://github.com/metmajer/jenkins-test-kitchen-ansible

- diferencias entre herramientas de aprovisionamiento
https://blog.gruntwork.io/why-we-use-terraform-and-not-chef-puppet-ansible-saltstack-or-cloudformation-7989dad2865c

- tutorial de tarea jenkins disparada con cambios en github
https://www.mirantis.com/blog/intro-to-cicd-how-to-make-jenkins-build-on-github-changes/

- diferencias entre máquinas virtuales y contenedores docker
https://stackoverflow.com/questions/16047306/how-is-docker-different-from-a-virtual-machine?rq=1

- ejemplos de molecule
https://github.com/metacloud/molecule
https://oteemo.com/2017/06/29/test-infrastructure-molecule/
