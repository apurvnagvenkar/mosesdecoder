from nltk.tokenize.moses import MosesTokenizer
import argparse

tokenizer = MosesTokenizer()


def generate_final_alignment_and_parallel_data(alignment_file, incorrect_file, correct_file, out_alignment_file, out_inc_file, out_cor_file):
    """
    Takes the input of alignment file generated from errant and inc & cor file and generates the Moses tokenized files
    of inc and cor by maintaining the alignement
    :param alignment_file:
    :param incorrect_file:
    :param correct_file:
    :param out_alignment_file:
    :param out_inc_file:
    :param out_cor_file:
    :return:
    """
    align_reader = open(alignment_file, 'r')
    inc_reader = open(incorrect_file, 'r')
    cor_reader = open(correct_file, 'r')

    out_align_writer = open(out_alignment_file, 'w')
    out_inc_writer = open(out_inc_file, 'w')
    out_cor_writer = open(out_cor_file, 'w')

    count = 0
    incorrect_list = inc_reader.readlines()
    correct_list = cor_reader.readlines()
    for align in align_reader.readlines():
 #       print align
        inc = incorrect_list[count]
        cor = correct_list[count]
#        print inc, count
        inc_list = inc.split()
        cor_list = cor.split()

        inc_align_list, cor_align_list = [], []
        for align_token in align.split():
            align_tok_split = align_token.split('-')
            if len(align_tok_split) > 2:
                if align_token[0] == '-':
                    inc_id = 0
                    cor_id = align_tok_split[-1]
                elif '--' in align_token:
                        align_tok_split = align_token.split('--')
                        inc_id = align_tok_split[0]
                        cor_id = 0
                else:
                    print 'exception not caught'

            else:
                inc_id, cor_id = int(align_tok_split[0]), int(align_tok_split[1])
            if inc_id not in inc_align_list:
                inc_align_list.append(inc_id)
            if cor_id not in cor_align_list:
                cor_align_list.append(cor_id)

        if max(inc_align_list) == len(inc_list) - 1 or max(cor_align_list) == len(cor_list) - 1:
            out_align_writer.write(align.strip()+"\n")
            out = []
            for inc_word in inc.split():
                t = tokenizer.tokenize(text=inc_word.decode('utf-8'))
                if len(t) > 1:
                    out.append(inc_word)
                else:
                    out.append(t[0].encode('utf-8'))
            out_inc_writer.write(' '.join(out).strip()+"\n")

            out = []
            for cor_word in cor.split():
                t = tokenizer.tokenize(text=cor_word.decode('utf-8'))
                if len(t) > 1:
                    out.append(cor_word)
                else:
                    out.append(t[0].encode('utf-8'))
            out_cor_writer.write(' '.join(out).strip() + "\n")
        else:
            pass
#            print inc, " --- ", cor, max(inc_align_list), len(inc_list), max(cor_align_list), len(cor_list)
        count += 1
    out_align_writer.close()
    out_inc_writer.close()
    out_cor_writer.close()

parser = argparse.ArgumentParser()
parser.add_argument("-align_file", dest="alignment_file", required=True, help="alignment file")
parser.add_argument("-inc", dest="incorrect_file", required=True, help="incorrect file")
parser.add_argument("-cor", dest="correct_file", required=True, help="correct file")

parser.add_argument("-out_align_file", dest="out_alignment_file", required=True, help="out_alignment file")
parser.add_argument("-out_inc", dest="out_incorrect_file", required=True, help="out_incorrect file")
parser.add_argument("-out_cor", dest="out_correct_file", required=True, help="out_correct file")

args = parser.parse_args()

generate_final_alignment_and_parallel_data(alignment_file=args.alignment_file,
                                           incorrect_file=args.incorrect_file,
                                           correct_file=args.correct_file,
                                           out_alignment_file=args.out_alignment_file,
                                           out_inc_file=args.out_incorrect_file,
                                           out_cor_file=args.out_correct_file)