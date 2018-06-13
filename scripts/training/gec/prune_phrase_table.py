import argparse
import gzip

def prune_phrase_table(input_phrase_table, output_phrase_table):
    """

    :param input_phrase_table:
    :param output_phrase_table:
    :return:
    """
    f=gzip.open(input_phrase_table,'rb')
    f_write = gzip.open(output_phrase_table, 'w')
    incorrect_phrase_dict, correct_phrase_dict = {}, {}
    phrase_dict = {}
    for line in f.readlines():
        line_split = line.split("|||")
        incorrect_phrase = line_split[0].strip()
        correct_phrase = line_split[1].strip()

        if incorrect_phrase in incorrect_phrase_dict:
            incorrect_phrase_dict[incorrect_phrase]+=1
        else:
            incorrect_phrase_dict[incorrect_phrase] =1

        if correct_phrase in correct_phrase_dict:
            correct_phrase_dict[correct_phrase]+=1
        else:
            correct_phrase_dict[correct_phrase] =1

        phrase_dict[line] = {
            "incorrect_phrase": incorrect_phrase,
            "correct_phrase": correct_phrase,
            "score": line_split[2],
            "align": line_split[3],
            "weight": line_split[4],
            "extra": line_split[5],

        }
#    final_phrase_list = []
    for phrase_line in phrase_dict:
        incorrect_phrase = phrase_dict[phrase_line]["incorrect_phrase"]
        correct_phrase = phrase_dict[phrase_line]["correct_phrase"]
        score = phrase_dict[phrase_line]["score"]
        align = phrase_dict[phrase_line]["align"]
        weight = phrase_dict[phrase_line]["weight"]
        extra = phrase_dict[phrase_line]["extra"]

        if incorrect_phrase_dict[incorrect_phrase] == 1 and correct_phrase_dict[correct_phrase] == 1:
            pass
        else:
            f_write.write(incorrect_phrase+"|||"+correct_phrase+"|||"+score+"|||"+align+"|||"+weight+"|||"+extra+"|||\n")

    f_write.close()



parser = argparse.ArgumentParser()
parser.add_argument("-inp_pt", dest="input_phrase_table", required=True, help="input phrase table")
parser.add_argument("-out_pt", dest="output_phrase_table", required=True, help="incorrect file")
args = parser.parse_args()

prune_phrase_table(input_phrase_table=args.input_phrase_table, output_phrase_table=args.output_phrase_table)