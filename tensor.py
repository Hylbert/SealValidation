import tensorflow as tf

# Verifica se o TensorFlow pode acessar a GPU
physical_devices = tf.config.list_physical_devices('GPU')
if physical_devices:
    print(f"TensorFlow encontrou {len(physical_devices)} GPU(s).")
    for gpu in physical_devices:
        print(gpu)
else:
    print("TensorFlow não encontrou nenhuma GPU.")
