/**
 * Created by Eric Liang on 2019/9/25.
 */

public class AsyncOperationRegister {
    private static final Map<String, IAsyncOperation> registerMethods = new Map<String, IAsyncOperation>{};

    // Register Async Operation Handlers
    static {
        for (ApexTypeImplementor interfaceImpl : [
                SELECT ClassName, ClassNamespacePrefix
                FROM ApexTypeImplementor
                WHERE InterfaceName = 'IAsyncOperation' AND IsConcrete = TRUE
        ]) {
            register(interfaceImpl.ClassName, (IAsyncOperation) Type.forName(interfaceImpl.ClassNamespacePrefix, interfaceImpl.ClassName).newInstance());
        }
    }

    public static void register(String method, IAsyncOperation handler) {
        registerMethods.put(method, handler);
    }

    public static void unRegister(String method) {
        registerMethods.remove(method);
    }

    public static IAsyncOperation getMethod(String method) {
        return registerMethods.get(method);
    }

}