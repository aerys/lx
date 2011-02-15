<?php

define('CRLF', "\n");

class WebService
{
  const SOAP_XML_SCHEMA_VERSION		= 'http://www.w3.org/2001/XMLSchema';
  const SOAP_XML_SCHEMA_INSTANCE	= 'http://www.w3.org/2001/XMLSchema-instance';
  const SOAP_SCHEMA_ENCODING		= 'http://schemas.xmlsoap.org/soap/encoding/';
  const SOAP_XML_SCHEMA_MIME		= 'http://schemas.xmlsoap.org/wsdl/mime/';
  const SOAP_ENVELOP			= 'http://schemas.xmlsoap.org/soap/envelope/';
  const SCHEMA_SOAP_HTTP		= 'http://schemas.xmlsoap.org/soap/http';
  const SCHEMA_SOAP			= 'http://schemas.xmlsoap.org/wsdl/soap/';
  const SCHEMA_WSDL			= 'http://schemas.xmlsoap.org/wsdl/';
  const SCHEMA_WSDL_HTTP		= 'http://schemas.xmlsoap.org/wsdl/http/';
  const SCHEMA_DISCO			= 'http://schemas.xmlsoap.org/disco/';
  const SCHEMA_DISCO_SCL		= 'http://schemas.xmlsoap.org/disco/scl/';
  const SCHEMA_DISCO_SOAP		= 'http://schemas.xmlsoap.org/disco/soap/';

  private $SIMPLE_TYPES		= array('string', 'int', 'float', 'bool',
					'double', 'integer', 'boolean',
					'varstring', 'varint', 'varfloat', 'varbool',
					'vardouble', 'varinteger', 'varboolean');

  private $_ClassName	= '';
  private $_Namespace	= '';

  public function WSDLService($my_className,
			     $my_namespace	= null)
  {
    $this->_ClassName = $my_className;
    $this->_Namespace = $my_namespace ? $my_namespace : $this->_ClassName;

    switch (strtolower($_SERVER['QUERY_STRING']))
    {
      case 'wsdl' :
	$this->echoWSDL();
	break ;
      default :
	if (isset($_SERVER['HTTP_SOAPACTION']))
	  $this->createSOAPServer();
	else
	  $this->echoInfo();
    }
  }

  private function createSOAPServer()
  {
    $soap_server = new SoapServer('http://' . $_SERVER['HTTP_HOST']
				  . $_SERVER['PHP_SELF'] . '?WSDL');
    $soap_server->setClass($this->_ClassName);
    $soap_server->handle();
  }

  private function echoInfo()
  {
    $this->_Struct = $this->toStruct();

    echo '<html><head><title>WSDLService - ' . $this->_Namespace
      . '::' . $this->_ClassName . '</title></head><body style="margin:0;font-family:sans-serif">'
      . '<div style="background-color:orange;color:#white;padding:20;font-size:20;font-weight:bold"><a href="'
      . 'http://' . $_SERVER['HTTP_HOST'] . $_SERVER['PHP_SELF'] . '?WSDL' . '" style="text-decoration:none;color:white">'
      . $this->_Namespace . '::' . $this->_ClassName . '</a></div><ul style="font-size:12">';

    foreach ($this->_Struct['methods'] as $methodName => $method)
    {
      echo '<li><em>' . $method['return']['type'] . '</em> <b>'  . $methodName . '</b>(';
      foreach ($method['args'] as $argName => $arg)
      {
	echo '<em>' . $arg['type'] . '</em> ' . $argName;
      }
      echo ')<p style="margin-top:3">' . $method['description'] . '</p></li>';
    }
    echo '</ul></body></html>';
  }

  private function echoWSDL()
  {
    $this->_WSDL = new DOMDocument('1.0', 'utf-8');
    $this->_Struct = $this->toStruct();

    $this->createWSDLDefinitions();

    header('Content-type: text/xml');
    echo $this->_WSDL->saveXML();
  }

  private function toStruct()
  {
    $rClass = new ReflectionClass($this->_ClassName);

    // properties
    $properties = $this->propertiesToStruct($rClass);
    //methods
    $methods = $this->methodsToStruct($rClass);

    $class = array('name'	=> $rClass->getName(),
		   'methods'	=> $methods,
		   'properties'	=> $properties);

    return ($class);
  }

  private function methodsToStruct($my_rClass)
  {
    $methods = array();
    // methods
    foreach ($my_rClass->getMethods() as $i => $rMethod)
    {
      $methodName = $rMethod->getName();
      if ($rMethod->isPublic() && $methodName != '__destruct'
	  && !$rMethod->isConstructor())
      {
	$docComment = $rMethod->getDocComment();

	// description
	$description = trim(str_replace('/**', '', substr($docComment, 0,
							  strpos($docComment, '@'))));
	$description = trim(substr($description, strpos($description, '*') + 1,
				   strpos($description, '*', 1) - 1));

	// params
	$params = $this->methodArgumentsToStruct($rMethod);

	// return
	$return = $this->methodReturnToStruct($rMethod);

	$methods[$methodName] = array('description'	=> $description,
				      'args'		=> $params,
				      'return'		=> $return);

      }
    }

    return ($methods);
  }

  private function methodReturnToStruct($my_rMethod)
  {
    $docComment = $my_rMethod->getDocComment();
    preg_match_all('~@return\s(\S+)~', $docComment, $return);
    if (isset($return[1][0]))
    {
      $type = str_replace('[]', '', $return[1][0], $arrayDepth);
    }
    else
    {
      $type = 'void';
      $arrayDepth = 0;
    }
    $namespace = str_repeat('ArrayOf', $arrayDepth);

    $isArray = false;
    if ($arrayDepth > 0 && $type != 'void'
	&& in_array($type, $this->SIMPLE_TYPES))
      $isArray = true;

    $isObject = false;
    if ($type != 'void' && !in_array($type, $this->SIMPLE_TYPES))
      $isObject = true;

    $return = array('type'	=> $type,
		    'wsdltype'	=> $namespace . $type,
		    'depth'	=> $arrayDepth,
		    'is_array'	=> $isArray,
		    'is_object'	=> $isObject);

    return ($return);
  }

  private function methodArgumentsToStruct($my_rMethod)
  {
    $docComment = $my_rMethod->getDocComment();
    $params = array();
    preg_match_all('~@param\s(\S+)~', $docComment, $docParams);

    foreach ($my_rMethod->getParameters() as $j => $rParam)
    {
      $type = $rParam->getClass() ? $rParam->getClass()->getName()
	: $docParams[1][$j];
      $type = str_replace('[]', '', $type, $arrayDepth);
      $namespace = str_repeat('ArrayOf', $arrayDepth);

      $isArray = false;
      if ($arrayDepth > 0 && in_array($type, $this->SIMPLE_TYPES))
	$isArray = true;

      $isObject = false;
      if (!in_array($type, $this->SIMPLE_TYPES) && new ReflectionClass($type))
	$isObject = true;

      $params[$rParam->getName()] = array('type'	=> $type,
					  'wsdltype'	=> $namespace . $type,
					  'depth'	=> $arrayDepth,
					  'is_array'	=> $isArray,
					  'is_object'	=> $isObject);
    }

    return ($params);
  }

  private function propertiesToStruct($my_rClass)
  {
    $rProperties = $my_rClass->getProperties();
    $properties = array();
    foreach ($rProperties as $property)
    {
      if ($property->isPublic())
      {
	$docComment = $property->getDocComment();

	preg_match_all('~@var\s(\S+)~', $docComment, $var);

	$type = str_replace('[]', '', $var[1][0], $arrayDepth);
	$namespace = str_repeat('ArrayOf', $arrayDepth);

	$properties[$property->getName()] = array('type'	=> $type,
						  'wsdltype'	=> $namespace . $type,
						  'depth'	=> $arrayDepth,
						  'is_array'	=> $isArray,
						  'is_object'	=> $isObject);
	$isArray = false;
	if ($arrayDepth > 0 && $type != 'void'
	    && in_array($type, $this->SIMPLE_TYPES))
	  $isArray = true;

	$isObject = false;
	if ($type != 'void' && !in_array($type, $this->SIMPLE_TYPES))
	  $isObject = true;

      }
    }

    return ($properties);
  }

  private function createWSDLDefinitions()
  {
    $wsdl_definitions = $this->_WSDL->createElement('definitions');
    $wsdl_definitions->setAttribute('name', $this->_Struct['name']);
    $wsdl_definitions->setAttribute('targetNamespace', 'urn:' . $this->_Struct['name']);
    $wsdl_definitions->setAttribute('xmlns:typens', 'urn:' . $this->_Struct['name']);
    $wsdl_definitions->setAttribute('xmlns:xsd', WSDLService::SOAP_XML_SCHEMA_VERSION);
    $wsdl_definitions->setAttribute('xmlns:soap', WSDLService::SCHEMA_SOAP);
    $wsdl_definitions->setAttribute('xmlns:soapenc', WSDLService::SOAP_SCHEMA_ENCODING);
    $wsdl_definitions->setAttribute('xmlns:wsdl', WSDLService::SCHEMA_WSDL);
    $wsdl_definitions->setAttribute('xmlns', WSDLService::SCHEMA_WSDL);

    // types
    $wsdl_definitions->appendChild($this->createWSDLTypes());

    // messages
    foreach ($this->createWSDLMessages() as $message)
      $wsdl_definitions->appendChild($message);

    // portTypes
    $wsdl_definitions->appendChild($this->createWSDLPortType());

    // binding
    $wsdl_definitions->appendChild($this->createWSDLBinding());

    // service
    $wsdl_definitions->appendChild($this->createWSDLService());

    $this->_WSDL->appendChild($wsdl_definitions);
  }

  private function createWSDLPortType()
  {
    $wsdl_portType = $this->_WSDL->createElement('portType');
    $wsdl_portType->setAttribute('name', $this->_Struct['name'] . 'Port');

    foreach ($this->_Struct['methods'] as $methodName => $method)
    {
      // operation
      $wsdl_operation = $this->_WSDL->createElement('operation');
      $wsdl_operation->setAttribute('name', $methodName);

      // documentation
      $wsdl_operation_documentation = $this->_WSDL->createElement('documentation');
      $wsdl_operation_documentation->appendChild($this->_WSDL->createTextNode($method['description']));
      $wsdl_operation->appendChild($wsdl_operation_documentation);

      // input
      $wsdl_operation_input = $this->_WSDL->createElement('input');
      $wsdl_operation_input->setAttribute('message', 'typens:'.$methodName);
      $wsdl_operation->appendChild($wsdl_operation_input);

      // output
      $wsdl_operation_output = $this->_WSDL->createElement('output');
      $wsdl_operation_output->setAttribute('message', 'typens:' . $methodName.'Response');
      $wsdl_operation->appendChild($wsdl_operation_output);

      $wsdl_portType->appendChild($wsdl_operation);
    }

    return ($wsdl_portType);
  }

  private function createWSDLMessages()
  {
    $messages = array();

    foreach ($this->_Struct['methods'] as $methodName => $method)
    {
      // input
      $wsdl_message_input = $this->_WSDL->createElement('message');
      $wsdl_message_input->setAttribute('name', $methodName);

      foreach ($method['args'] as $paramName => $param)
      {
	$wsdl_message_part = $this->_WSDL->createElement('part');
	$wsdl_message_part->setAttribute('name', $paramName);
	if (!$param['is_array'] && !$param['is_object'])
	  $wsdl_message_part->setAttribute('type', 'xsd:' . $param['type']);
	else
	  $wsdl_message_part->setAttribute('type', 'typens:' . $param['type']);

	$wsdl_message_input->appendChild($wsdl_message_part);
      }

      $messages[] = $wsdl_message_input;

      // output
      $wsdl_message_output = $this->_WSDL->createElement('message');
      $wsdl_message_output->setAttribute('name', $methodName . 'Response');

      $return = $method['return'];
      $wsdl_message_part = $this->_WSDL->createElement('part');
      $wsdl_message_part->setAttribute('name', $methodName . 'Response');
      if (!$return['is_array'] && !$return['is_object'])
	$wsdl_message_part->setAttribute('type', 'xsd:' . $return['wsdltype']);
      else
	$wsdl_message_part->setAttribute('type', 'typens:' . $return['wsdltype']);

      $wsdl_message_output->appendChild($wsdl_message_part);

      $messages[] = $wsdl_message_output;
    }

    return ($messages);
  }

  private function createWSDLTypes()
  {
    $wsdl_types = $this->_WSDL->createElement('types');

    $wsdl_schema = $this->_WSDL->createElement('xsd:schema');
    $wsdl_schema->setAttribute('xmlns', WSDLService::SOAP_XML_SCHEMA_VERSION);
    $wsdl_schema->setAttribute('targetNamespace', 'urn:' . $this->_Struct['name']);

    $wsdl_types->appendChild($wsdl_schema);

    return ($wsdl_types);
  }

  private function createWSDLBinding()
  {
    // wsdl binding
    $wsdl_binding = $this->_WSDL->createElement('binding');
    $wsdl_binding->setAttribute('name', $this->_Struct['name'].'Binding');
    $wsdl_binding->setAttribute('type', 'typens:' . $this->_Struct['name'] . 'Port');

    // soap binding
    $soap_binding = $this->_WSDL->createElement('soap:binding');
    $soap_binding->setAttribute('style', 'rpc');
    $soap_binding->setAttribute('transport', WSDLService::SCHEMA_SOAP_HTTP);

    $wsdl_binding->appendChild($soap_binding);

    foreach ($this->_Struct['methods'] as $methodName => $method)
    {
      // wsdl operation
      $wsdl_operation = $this->_WSDL->createElement('operation');
      $wsdl_operation->setAttribute('name', $methodName);
      $wsdl_binding->appendChild($wsdl_operation);

      // soap operation
      $soap_operation = $this->_WSDL->createElement('soap:operation');
      $soap_operation->setAttribute('soapAction', 'urn:' . $this->_Struct['name'] . 'Action');
      $wsdl_operation->appendChild($soap_operation);

      // input
      $wsdl_input = $this->_WSDL->createElement('input');
      $soap_body = $this->_WSDL->createElement('soap:body');
      $soap_body->setAttribute('use', 'encoded');
      $soap_body->setAttribute('namespace', 'urn:' . $this->_Namespace);
      $soap_body->setAttribute('encodingStyle', WSDLService::SOAP_SCHEMA_ENCODING);
      $wsdl_input->appendChild($soap_body);
      $wsdl_operation->appendChild($wsdl_input);

      // output
      $wsdl_output = $this->_WSDL->createElement('output');
      $soap_body = $this->_WSDL->createElement('soap:body');
      $soap_body->setAttribute('use', 'encoded');
      $soap_body->setAttribute('namespace', 'urn:' . $this->_Namespace);
      $soap_body->setAttribute('encodingStyle', WSDLService::SOAP_SCHEMA_ENCODING);
      $wsdl_output->appendChild($soap_body);
      $wsdl_operation->appendChild($wsdl_output);
    }

    return ($wsdl_binding);
  }

  private function createWSDLService()
  {
    $wsdl_service = $this->_WSDL->createElement('service');
    $wsdl_service->setAttribute('name', $this->_Struct['name']);

    $wsdl_port = $this->_WSDL->createElement('port');
    $wsdl_port->setAttribute('name', $this->_Struct['name'] . 'Port');
    $wsdl_port->setAttribute('binding', 'typens:' . $this->_Struct['name'] . 'Binding');

    $soap_address = $this->_WSDL->createElement('soap:address');
    $soap_address->setAttribute('location', 'http://' . $_SERVER['HTTP_HOST']
				. $_SERVER['PHP_SELF']);

    $wsdl_port->appendChild($soap_address);
    $wsdl_service->appendChild($wsdl_port);

    return ($wsdl_service);
  }

}

?>