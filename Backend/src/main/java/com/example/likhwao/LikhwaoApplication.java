package com.example.likhwao;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;


@SpringBootApplication
@EnableJpaAuditing
@EntityScan(basePackages = {"com.example.likhwao.Entity" ,"com.example.likhwao.Entity.USER"})
public class LikhwaoApplication {

	public static void main(String[] args) {
		SpringApplication.run(LikhwaoApplication.class, args);
	}

}
