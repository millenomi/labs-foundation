package net.infinite_labs.basics;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@Retention(RetentionPolicy.RUNTIME)
public @interface Contains {
	Class<?> value();
}
