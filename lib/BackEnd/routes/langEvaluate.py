from datasets import load_dataset, load_metric
from transformers import pipeline

# Load the SQuAD 2.0 dataset
dataset = load_dataset('squad_v2')

# Load the question answering pipeline
model_name = "deepset/roberta-base-squad2"
nlp = pipeline('question-answering', model=model_name, tokenizer=model_name)

# Define the evaluation metric
metric = load_metric('squad_v2')

# Loop through the examples in the dataset and make predictions with the pipeline
for example in dataset['validation']:
    context = example['context']
    question = example['question']
    answer = example['answers'][0]['text']
    prediction = nlp(question=question, context=context)['answer']

    # Update the evaluation metric with the true and predicted answers
    metric.add(prediction=prediction, reference=answer)

# Calculate the evaluation metric
result = metric.compute()
print(result)
