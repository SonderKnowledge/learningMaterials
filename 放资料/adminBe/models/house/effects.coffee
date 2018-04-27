import uuid from 'uuid'
import services from '../../services/house'
import validate from '../../utils/validate'
export default ({
  type
}) ->
# 查 无对应
# 实际包含两个动作
# 一 查到一条记录
# 二 发起同步action修改状态，把拿到的记录存进去
# 覆盖 saveall
  reload: (action, {put}) ->
    console.log '这里是 house model reload 调用Service'
    result = yield services.reload()

    if result?
      yield put
        type: type.houseSaveAll
        payload: result.results
      yield payload.success result.results
    else
      yield payload.fail 'house reload error'

    return

  fetch: ({payload}, {put}) ->
    console.log '这里是 house model fetch 调用Service'
    validate.exist payload,['objectId']

    result = yield  services.fetch payload.objectId

    if result?
      yield put
        type: type.houseSave
        payload: result
      yield payload.success result
    else
      yield payload.fail 'house fetch error'

    return

# 增一个 save
  create: ({payload}, {put}) ->
    console.log '这里是 house model create 调用Service'
    validate.exist payload,['province', 'city', 'district', 'communityAddress']

    result = yield services.create payload

    if result?
      yield put
        type: type.houseSave
        payload: result
      yield payload.success result
    else
      yield payload.fail 'house create error'


    return

# 改 patch
  update: ({payload}, {put}) ->
    console.log '这里是 house model update 调用Service'
    validate.exist payload,['objectId']

    yield services.update payload
    result = yield services.fetch payload.objectId

    if result?
      yield put
        type: type.housePatch
        payload: result
      yield payload.success result
    else
      yield payload.fail 'house update error'

    return

# 删 remove
  delete: ({payload}, {put}) ->
    console.log '这里是 house model delete 调用Service'
    validate.exist payload,['objectId']

    result = yield services.delete payload.objectId

    if result?
      yield put
        type: type.houseRemove
        payload:
          objectId: payload.objectId
      yield payload.success payload.objectId
    else
      yield payload.fail 'house delete error'

    return

# # 增加多个，暂时没用
#   createAll: (action, {put}) ->
#     console.log '这里是 house model reload 调用Service'
#     results = []
#     for value in payload.array
#       try
#         # validate.exist payload,['isOnline', 'province', 'city', 'district', 'communityAddress']
#         result = yield services.create value
#       catch error
#         console.log '调用出错'
#         throw new Error error
#       results[results.length] = result
#
#     newAction =
#       type: type.houseSaveAll
#       payload:
#         array: results
#
#     console.log 'createAll调用成功，修改状态'
#     yield put newAction
#
#     return
