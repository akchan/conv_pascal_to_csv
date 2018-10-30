# conv_pascal_to_csv

Annotation format converter from Pascal VOC format to [fizyr/keras-retinanet](https://github.com/fizyr/keras-retinanet) csv format

This script improve object detection development workflow with [fizyr/keras-retinanet](https://github.com/fizyr/keras-retinanet).

## Description

Around object detection development, it is a hard work to preparing training data. Some software (ex, [LabelImg](https://github.com/tzutalin/labelImg)) help this situation but doesn't output with csv format of [fizyr/keras-retinanet](https://github.com/fizyr/keras-retinanet).

Using this script `conv_pascal_to_csv.rb`, you can convert annotations from Pascal VOC xml format with which LabelImg outputs, to csv format which [fizyr/keras-retinanet](https://github.com/fizyr/keras-retinanet) requires.

## Requirement

- Ruby 2 (tested with ruby 2.5.1)

## Demo

```sh
git clone https://github.com/akchan/conv_pascal_to_csv.git
cd conv_pascal_to_csv/sample/retinanet_csv_format
ruby ../../conv_pascal_to_csv.rb --annotation-path ../PascalVOC_format/Annotations --image-path ../PascalVOC_format/JPEGImages
```

Then, `conv_pascal_to_csv.rb` creates some files/directories like below.

- `retinanet_csv_format`
	- `csv`
		- `annotations.csv`
		- `val_annotations.csv`
		- `classes.csv`
	- `images`
		- jpeg files

You can give these directory to train.py of [fizyr/keras-retinanet](https://github.com/fizyr/keras-retinanet) like below.

```sh
cd PATH_TO_KERAS_RETINANET
python ./keras_retinanet/bin/train.py csv PATH_TO_ANNOTATIONS PATH_TO_CLASSES --val-annotations PATH_TO_VAL_ANNOTATIONS
```

## Sources

- [Sample images](https://github.com/vc1492a/Hey-Waldo)

## Licence

MIT licence

See [LICENCE](https://github.com/akchan/conv_pascal_to_csv/blob/master/LICENSE) file.

## Author

akchan (Satoshi Funayama, [GitHub](https://github.com/akchan), [twitter](https://twitter.com/akcharine))
