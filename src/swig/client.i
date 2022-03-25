%nodefaultctor QmlBackend;
%nodefaultdtor QmlBackend;
class QmlBackend : public QObject {
public:
    void emitNotifyUI(const char *command, const char *json_data);
};

extern QmlBackend *Backend;

%nodefaultctor Client;
%nodefaultdtor Client;
class Client : public QObject {
public:
    void requestServer(const QString &command,
                   const QString &json_data, int timeout = -1);
    void replyToServer(const QString &command, const QString &json_data);
    void notifyServer(const QString &command, const QString &json_data);

    LuaFunction callback;
};

extern Client *ClientInstance;

%{
void Client::callLua(const QString& command, const QString& json_data)
{
    Q_ASSERT(callback);

    lua_rawgeti(L, LUA_REGISTRYINDEX, callback);
    SWIG_NewPointerObj(L, this, SWIGTYPE_p_Client, 0);
    lua_pushstring(L, command.toUtf8());
    lua_pushstring(L, json_data.toUtf8());

    int error = lua_pcall(L, 3, 0, 0);
    if (error) {
        const char *error_msg = lua_tostring(L, -1);
        qDebug() << error_msg;
    }
}
%}