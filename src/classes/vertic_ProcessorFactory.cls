public class vertic_ProcessorFactory {

    public static vertic_AbstractProcessor getInstance(String processorName) {
        return getInstance(processorName, 'No Processor Type with Name: ' + processorName);
    }

    public static vertic_AbstractProcessor getInstance(String processorName, String errorMessage) {
        Type processorType = Type.forName(processorName);

        if (processorType == null) {
            throw new vertic_Structs.CommonException(errorMessage);
        }

        vertic_AbstractProcessor processorVar = (vertic_AbstractProcessor) processorType.newInstance();

        if (processorVar == null) {
            throw new vertic_Structs.CommonException('Unable to create Processor instance of type name: ' + processorName);
        }

        return processorVar;
    }

}