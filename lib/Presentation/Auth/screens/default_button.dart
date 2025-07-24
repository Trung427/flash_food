import 'package:flash_food/Core/app_colors.dart';
import 'package:flash_food/Core/response_conf.dart';
import 'package:flash_food/Core/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class DefaultButton extends StatefulWidget {
  DefaultButton(
      {Key? key,
      required this.btnContent,
      this.borderColor,
      this.function,
      this.btnIcon,
      this.contentColor,
      this.iconColor,
      this.bgColor})
      : super(key: key);
  final String btnContent;
  final IconData? btnIcon;
  final VoidCallback? function;
  final Color? iconColor;
  final Color? contentColor;
  final Color? bgColor;
  final Color? borderColor;

  @override
  State<DefaultButton> createState() => _DefaultButtonState();
}

class _DefaultButtonState extends State<DefaultButton> {
  double _scale = 1.0;
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.95;
      _isPressed = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
      _isPressed = false;
    });

  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: SizedBox(
          height: getHeight(52),
          width: double.infinity,
          child: FilledButton(
              style: ButtonStyle(
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                      side: BorderSide(
                        color: widget.borderColor ?? Pallete.orangePrimary,
                      ),
                      borderRadius: BorderRadius.circular(getSize(100)))),
                  backgroundColor:
                      MaterialStatePropertyAll(widget.bgColor ?? Pallete.orangePrimary)),
              onPressed: widget.function,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  widget.btnIcon != null
                      ? Row(
                          children: [
                            Icon(
                              widget.btnIcon,
                              color: widget.iconColor ?? Colors.white,
                              size: getSize(20),
                            ),
                            const Gap(8)
                          ],
                        )
                      : const SizedBox(),
                  Text(
                    widget.btnContent,
                    style: TextStyles.bodyMediumSemiBold
                        .copyWith(color: widget.contentColor ?? Pallete.neutral10, fontSize: getFontSize(14)),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
