import dd from 'ddeyes'
import _request from './request'

getBaseUrl = ({
  withSSL = false
  host = 'localhost'
  port = '3000'
  prefix = ''
}) =>
  [
    # http(s)
    'http'
    if withSSL? and
    (withSSL is true)
    then 's'
    else ''

    '://'

    host

    # port
    if ("#{port}" is '0') or ("#{port}" is '80')
    then ''
    else ":#{port}"

    # prefix
    if prefix is ''
    then ''
    else "/#{prefix}"

  ].join ''

getUrlObj = ({
  name
  value
  baseUrl
  baseHeaders
}) =>
  # name value 就是business里面的user等
  # baseUrl是拼接的'http://192.168.0.192:7001'
  # baseHeaders是{ Content-Type: 'application/json' }
  urlObj = {}

  if typeof value is 'string'
    if value is 'login'
      urlObj = 
        signup:
          uri: => "#{baseUrl}/signup"
          method: 'POST'
          headers: baseHeaders
        login: 
          uri: => "#{baseUrl}/login"
          method: 'POST'
          headers: baseHeaders
    else
      urlObj = 
        create:
          uri: => "#{baseUrl}/#{name}"
          method: 'POST'
          headers: baseHeaders
        fetch: 
          uri: ({
            objectId
          }) => "#{baseUrl}/#{name}/#{objectId}"
          method: 'GET'
          headers: baseHeaders
        fetchAll:
          uri: => "#{baseUrl}/#{name}"
          method: 'GET'
          headers: baseHeaders
        update:
          uri: ({
            objectId
          }) => "#{baseUrl}/#{name}/#{objectId}"
          method: 'PUT'
          headers: baseHeaders
        delete:
          uri: ({
            objectId
          }) => "#{baseUrl}/#{name}/#{objectId}"
          method: 'DELETE'
          headers: baseHeaders

  else if typeof value is 'function'
    urlObj = value(baseUrl)

  else if typeof value is 'object'
    urlObj =
      uri:
        if value.uri?
        then value.uri baseUrl
        else "#{baseUrl}/#{name}"
      method: value.method or 'POST'
      headers: {
        baseHeaders...
        value.headers...
      }

  else
    urlObj =
      uri: baseUrl
      method: 'GET'
      headers: baseHeaders

  "#{name}": urlObj

getUrlObjs = ({
  urlConf
  business
}) =>
  baseUrl = getBaseUrl urlConf
  baseHeaders =
    if urlConf?.headers?
    then (
      if urlConf.headers["Content-Type"]?
      then urlConf.headers
      else {
        urlConf.headers...
        "Content-Type": 'application/json'
      }
    )
    else "Content-Type": 'application/json'

  (
    Object.keys business
  ).reduce (r, c) =>
    {
      r...
      (
        getUrlObj {
          name: "#{c}"
          value: business["#{c}"]
          baseUrl
          baseHeaders
        }
      )...
    }
  , {}

getServices = ({
  urlObjs
  request = _request
}) =>

  (
    Object.keys urlObjs
  ).reduce (r, c) =>
    {
      r...
      "#{c}": (
        data
      ) =>
        urlObj = urlObjs["#{c}"]
        url =
          if data?.objectId?
          then urlObj.uri
            objectId: data.objectId
          else urlObj.uri()
        request url
        , {
          method: urlObj.method
          headers: urlObj.headers
          data
        }
  }
  , {}

getGroupServices = ({
  urlObjs
  request
}) =>

  (
    Object.keys urlObjs
  ).reduce (r, c) =>
    {
      r...
      "#{c}": getServices
        urlObjs: urlObjs["#{c}"]
    }
  , {}

export {
  getBaseUrl
  getUrlObj
  getUrlObjs
  getGroupServices
}
