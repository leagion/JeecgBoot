import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class OllamaModelFetcher {
    public static void main(String[] args) {
        try {
            // Execute the command to pull the model
            ProcessBuilder processBuilder = new ProcessBuilder("ollama", "pull", "nomic-embed-text");
            processBuilder.redirectErrorStream(true);
            Process process = processBuilder.start();

            // Read the output from the command
            BufferedReader reader = new BufferedReader(
                new InputStreamReader(process.getInputStream()));

            String line;
            while ((line = reader.readLine()) != null) {
                System.out.println(line);
            }

            int exitCode = process.waitFor();
            System.out.println("\nExited with code " + exitCode);

        } catch (IOException | InterruptedException e) {
            e.printStackTrace();
        }
    }
}